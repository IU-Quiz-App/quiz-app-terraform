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
        return response(400, {"error": "Missing game_session_uuid"})

    try:    
        game_session_item = get_game_session(game_session_uuid)
        if not game_session_item:
            return response(404, {"error": "Game session not found"})

        next_question = get_next_question(game_session_uuid, game_session_item)
        send_next_question_to_all_players(game_session_uuid, next_question)
        new_question_index = int(game_session_item.get("current_question", 0))
        return response(200, {"message": "Next question sent to all players", "question_index": new_question_index})
    
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return response(500, {"error": str(e)})

def get_game_session(game_session_uuid):
    response = game_sessions_table.get_item(Key={"uuid": game_session_uuid})
    return response.get("Item")

def get_next_question(game_session_uuid, game_session_item):
    current_question_index = int(game_session_item.get("current_question", 0))
    next_question_index = current_question_index + 1

    logger.info(f"Updating game session {game_session_uuid} to question index {next_question_index}")

    game_sessions_table.update_item(
        Key={"uuid": game_session_uuid},
        UpdateExpression="SET current_question = :next_question_index",
        ExpressionAttributeValues={":next_question_index": next_question_index}
    )

    next_question = game_session_item["questions"][next_question_index]

    # Randomize answers
    answers = next_question["answers"]
    for answer in answers:
        answer["isTrue"] = False
    random.shuffle(answers)
    next_question["answers"] = answers

    logger.info(f"Next question with shuffled answers: {next_question}")
    return next_question

def send_next_question_to_all_players(game_session_uuid, next_question):
    logger.info(f"Sending next question to all clients in session: {game_session_uuid}")
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
                Data=json.dumps({"next_question": next_question})
            )
            logger.info(f"Sent next_question to {connection_id}")

        except apigateway_management.exceptions.GoneException:
            logger.info(f"Connection {connection_id} is gone")

def response(status_code, body):
    return {"statusCode": status_code, "body": json.dumps(body)}