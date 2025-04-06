import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
game_sessions_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "GET, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    body = json.loads(event["body"])

    #game_session_uuid = event["body"].get("game_session_uuid")
    game_session_uuid = body.get("game_session_uuid")
    user_uuid = body.get("user_uuid")
    nickname = body.get("nickname")
    #user_uuid = event["body"].get("user_uuid")
    #nickname = event["body"].get("nickname")

    if not game_session_uuid:
        logger.error("Missing game_session_uuid")
        return response(400, {"error": "Missing game_session_uuid"})
    if not user_uuid:
        logger.error("Missing user_uuid")
        return response(400, {"error": "Missing user_uuid"})
    if not nickname:
        logger.error("Missing nickname")
        return response(400, {"error": "Missing nickname"})
    
    new_user = {"user_uuid": user_uuid, "nickname": nickname}
    
    try:
        game_sessions_table.update_item(
            Key = {"uuid": game_session_uuid},
            UpdateExpression = "SET #users = list_append(#users, :new_user)",
            ExpressionAttributeValues = {":new_user": [new_user]},
            ConditionExpression="attribute_exists(#uuid)",
            ExpressionAttributeNames={
                "#uuid": "uuid",
                "#users": "users"
            }
        )
        
        logger.info(f"User {user_uuid} added successfully to game session {game_session_uuid}")
        return response(200, {"message": f"User {user_uuid} with nickname {nickname} added successfully to game session {game_session_uuid}"})
    
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        logger.error(f"Game session {game_session_uuid} does not exist")
        return response(400, {"error": "Game session does not exist"})
    
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return response(500, {"error": str(e)})


def response(status_code, body):
    return {"statusCode": status_code, "headers": CORS_HEADERS, "body": json.dumps(body)}