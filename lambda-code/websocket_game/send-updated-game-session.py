import json
import os
import logging
import boto3
import random

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
websocket_wss_api_endpoint = os.environ.get('WEBSOCKET_API_GATEWAY_ENDPOINT')
websocket_api_endpoint = f"{websocket_wss_api_endpoint.replace('wss', 'https')}/{stage}"

dynamodb = boto3.resource("dynamodb")
lambda_client = boto3.client("lambda")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")
game_sessions_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")

apigateway_management = boto3.client(
    "apigatewaymanagementapi",
    endpoint_url=websocket_api_endpoint
)

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    game_session_uuid = event.get("game_session_uuid")

    if not game_session_uuid:
        logger.info("Missing game_session_uuid")
        return {"statusCode": 400, "body": json.dumps({"error": "Missing game_session_uuid"})}

    try:
        result = lambda_client.invoke(
            FunctionName=f"get_game_session_{stage}",
            InvocationType="RequestResponse",
            Payload=json.dumps({"pathParameters": {"uuid": game_session_uuid}})
        )

        logger.info(f"Payload: {result}")
        body = json.loads(result["Payload"].read()).get("body")
        game_session_item = json.loads(body)


        if not game_session_item:
            return {"statusCode": 400, "body": json.dumps({"error": "Game session not found"})}

        send_updated_session_to_all_players(game_session_item)
        return {"statusCode": 200, "body": json.dumps({"message": "Session sent to all players"})}

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return {"statusCode": 500, "body": json.dumps({"error": str(e)})}

def send_updated_session_to_all_players(game_session_item):
    logger.info(f"Sending updated session to all clients in session: {game_session_item}")

    response = websocket_connections_table.scan(
        FilterExpression="game_session_uuid = :session",
        ExpressionAttributeValues={":session": game_session_item["uuid"]}
    )

    connections = response.get("Items", [])

    logger.info(f"Found {len(connections)} connections for session {game_session_item["uuid"]}: {connections}")

    for connection in connections:
        connection_id = connection["connection_uuid"]
        try:
            apigateway_management.post_to_connection(
                ConnectionId=connection_id,
                Data=json.dumps({
                    "action": "update-game-session",
                    "game_session": game_session_item
                }),
            )
            logger.info(f"Sent updated session to {connection_id}")

        except apigateway_management.exceptions.GoneException:
            logger.info(f"Connection {connection_id} is gone")