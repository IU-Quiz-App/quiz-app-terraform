import json
import boto3
import uuid
import datetime
import logging
import os
import base64

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
game_sessions_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
user_game_sessions_table = dynamodb.Table(f"iu-quiz-user-game-sessions-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    try:
        token = event["headers"].get("authorization", "")
        payload = decode_jwt_payload(token)

        if not payload:
            return response(401, {"error": "Invalid Token"})

        user_uuid = payload.get("oid")
        if not user_uuid:
            return response(401, {"error": "Invalid Token: Missing oid"})

        session_uuid = str(uuid.uuid4())
        nickname = payload.get("name", "").strip().split()[0] if payload.get("name") else None
        if not nickname:
            return response(400, {"error": "Invalid Token: Missing name"})

        created_at = datetime.datetime.now().isoformat()

        item = {
            "uuid": session_uuid,
            "created_by": user_uuid,
            "created_at": created_at,
            "users": [{"user_uuid": user_uuid, "nickname": nickname}],
        }

        game_sessions_table.put_item(Item=item)

        logger.info(f"Session created successfully: {item}")

        user_game_sessions_table.put_item(
            Item={
                "user_uuid": user_uuid,
                "game_session_uuid": session_uuid,
                "created_by": user_uuid,
                "created_at": created_at,
            }
        )
        logger.info(f"User game session created successfully: {user_uuid} - {session_uuid}")

        return response(200, {"message": "Session successfully created!", "session": item})

    except Exception as e:
        logger.error("Error creating session: %s", str(e), exc_info=True)
        return response(500, {"error": str(e)})
    

def decode_jwt_payload(token):
    token = token.replace("Bearer ", "")
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