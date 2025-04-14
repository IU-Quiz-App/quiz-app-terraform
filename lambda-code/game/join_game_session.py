import json
import boto3
import logging
import os
import base64

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
game_sessions_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
lambda_client = boto3.client("lambda")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "PUT, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    body = json.loads(event["body"])

    game_session_uuid = body.get("game_session_uuid")
    # nickname = body.get("nickname")

    if not game_session_uuid:
        logger.error("Missing game_session_uuid")
        return response(400, {"error": "Missing game_session_uuid"})
    # if not nickname:
    #     logger.error("Missing nickname")
    #     return response(400, {"error": "Missing nickname"})
    
    auth_header = event["headers"].get("authorization", "")
    token = auth_header.split(" ")[1] if " " in auth_header else auth_header
    payload = decode_jwt_payload(token)
    if not payload:
        return response(401, {"error": "Invalid Token"})
    
    user_uuid = payload.get("oid")
    if not user_uuid:
        return response(401, {"error": "Invalid Token: Missing oid"})
    
    nickname = payload.get("name", "").strip().split()[0] if payload.get("name") else None
    if not nickname:
        return response(400, {"error": "Invalid Token: Missing name"})
    
    new_user = {"user_uuid": user_uuid, "nickname": nickname}
    
    try:
        game_session = game_sessions_table.get_item(
            Key={"uuid": game_session_uuid}
        ).get("Item")

        logger.info(f"Game session: {game_session}")

        if not game_session:
            logger.error(f"Game session {game_session_uuid} does not exist")
            return response(400, {"error": "Game session does not exist"})

        if user_uuid in [user["user_uuid"] for user in game_session.get("users", [])]:
            logger.error(f"User {user_uuid} already in game session {game_session_uuid}")
            return response(409, {"error": "User already in game session"})

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

        update_game_session_response = lambda_client.invoke(
            FunctionName=f"send_updated_game_session_{stage}",
            InvocationType="Event",
            Payload=json.dumps({
                "game_session_uuid": game_session_uuid,
                "update_reason": "player-joined",
            })
        )

        logger.info(f"Update game session lambda invoked: {update_game_session_response}")
        
        logger.info(f"User {user_uuid} added successfully to game session {game_session_uuid}")
        return response(200, {"message": f"User {user_uuid} with nickname {nickname} added successfully to game session {game_session_uuid}"})
    
    except dynamodb.meta.client.exceptions.ConditionalCheckFailedException:
        logger.error(f"Game session {game_session_uuid} does not exist")
        return response(400, {"error": "Game session does not exist"})
    
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return response(500, {"error": str(e)})
    
def decode_jwt_payload(token):
    try:
        parts = token.split('.')
        if len(parts) != 3:
            raise ValueError("Invalid JWT format")

        payload_b64 = parts[1]
        padding = '=' * (-len(payload_b64) % 4)
        payload_b64 += padding

        payload_bytes = base64.urlsafe_b64decode(payload_b64)
        payload = json.loads(payload_bytes)

        return payload

    except Exception as e:
        logger.error("Failed to decode JWT payload: %s", str(e))
        return None

def response(status_code, body):
    return {"statusCode": status_code, "headers": CORS_HEADERS, "body": json.dumps(body)}