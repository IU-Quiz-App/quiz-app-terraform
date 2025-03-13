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
    current_question_index = event.get("current_question_index")

    if not game_session_uuid:
        return response(400, {"error": "Missing game_session_uuid"})
    if current_question_index is None:
        return response(400, {"error": "Missing current_question_index"})
    
    try:    
        game_session_item = get_game_session(game_session_uuid)
        if not game_session_item:
            return response(404, {"error": "Game session not found"})
        
        question = get_question(game_session_item, current_question_index)
        send_question_to_all_players(game_session_uuid, question)
        question_uuid = game_session_item["questions"][current_question_index]["uuid"]
        logger.info(f"Question uuid: {question_uuid}")
        return response(200, {"message": "Question sent to all players", "current_question_uuid": question_uuid})
    
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return response(500, {"error": str(e)})

def get_game_session(game_session_uuid):
    response = game_sessions_table.get_item(Key={"uuid": game_session_uuid})
    return response.get("Item")

def get_question(game_session_item, question_index):
    question = game_session_item["questions"][question_index]

    # Randomize answers
    answers = question["answers"]
    for answer in answers:
        answer["isTrue"] = False
    random.shuffle(answers)
    question["answers"] = answers

    logger.info(f"Question with shuffled answers: {question}")
    return question

def send_question_to_all_players(game_session_uuid, question):
    logger.info(f"Sending question to all clients in session: {game_session_uuid}")
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
                Data=json.dumps({"question": question})
            )
            logger.info(f"Sent question to {connection_id}")

        except apigateway_management.exceptions.GoneException:
            logger.info(f"Connection {connection_id} is gone")

def response(status_code, body):
    return {"statusCode": status_code, "body": body}