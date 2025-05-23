import json
import os
import logging
import boto3

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
websocket_wss_api_endpoint = os.environ.get('WEBSOCKET_API_GATEWAY_ENDPOINT')
websocket_api_endpoint = f"{websocket_wss_api_endpoint.replace('wss', 'https')}/{stage}"

dynamodb = boto3.resource("dynamodb")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")
game_sessions_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")

apigateway_management = boto3.client(
    "apigatewaymanagementapi",
    endpoint_url=websocket_api_endpoint
)

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    game_session_uuid = event.get("game_session_uuid")
    action_type = event.get("action_type")
    wait_seconds = event.get("wait_seconds")

    if not game_session_uuid:
        raise ValueError("Missing game_session_uuid")
    if not action_type:
        raise ValueError("Missing action_type")
    if wait_seconds is None:
        raise ValueError("Missing wait_seconds")
    
    try:    
        game_session_item = get_game_session(game_session_uuid)
        if not game_session_item:
            return response(404, {"error": "Game session not found"})
        
        send_action_message_to_all_players(game_session_uuid, action_type, wait_seconds)
        return response(200, {"message": f"Action {action_type} sent to all players"})
    
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return response(500, {"error": str(e)})

def get_game_session(game_session_uuid):
    response = game_sessions_table.get_item(Key={"uuid": game_session_uuid})
    return response.get("Item")

def send_action_message_to_all_players(game_session_uuid, action_type, wait_seconds):
    logger.info(f"Sending action {action_type} to all clients in session: {game_session_uuid}")
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
                Data=json.dumps({
                    "action": action_type,
                    "wait_seconds": wait_seconds,
                })
            )
            logger.info(f"Sent action {action_type} and wait seconds {wait_seconds} to {connection_id}")

        except apigateway_management.exceptions.GoneException:
            logger.info(f"Connection {connection_id} is gone")

def response(status_code, body):
    return {"statusCode": status_code, "body": body}