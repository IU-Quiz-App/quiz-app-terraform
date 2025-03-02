import json
import os
import logging
import boto3

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
websocket_wss_api_endpoint = os.environ.get('WEBSOCKET_API_GATEWAY_ENDPOINT')
websocket_api_endpoint = f"{websocket_wss_api_endpoint.replace('wss', 'https')}/{stage}"
dynamodb = boto3.resource("dynamodb")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")

apigateway_management = boto3.client(
    "apigatewaymanagementapi",
    endpoint_url=websocket_api_endpoint
)

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")
    logger.info(f"websocket api endpoint: {websocket_api_endpoint}")

    # `game_session_uuid` aus dem Event holen
    game_session_uuid = event.get("game_session_uuid")
    message = event.get("message")

    if not game_session_uuid or not message:
        return {"statusCode": 400, "body": json.dumps({"error": "Missing game_session_uuid or message"})}

    logger.info(f"Sending message to all clients in session: {game_session_uuid}")

    # Alle Verbindungen abrufen, die zur game_session_uuid gehören (Scan)
    response = websocket_connections_table.scan(
        FilterExpression="game_session_uuid = :session",
        ExpressionAttributeValues={":session": game_session_uuid}
    )

    connections = response.get("Items", [])

    logger.info(f"Found {len(connections)} connections for session {game_session_uuid}: {connections}")

    for connection in connections:
        connection_id = connection["connection_uuid"]
        try:
            apigateway_management.post_to_connection(
                ConnectionId=connection_id,
                Data=json.dumps({"message": message})
            )
            logger.info(f"Sent message to {connection_id}")

        except apigateway_management.exceptions.GoneException:
            logger.info(f"Connection {connection_id} is gone")

    return {"statusCode": 200, "body": json.dumps({"message": "Broadcast sent"})}
