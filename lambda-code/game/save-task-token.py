import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
dynamodb = boto3.resource("dynamodb")
game_sessions_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    game_session_uuid = event.get("game_session_uuid")
    task_token = event.get("task_token")

    if not game_session_uuid:
        return response(400, {"error": "Missing game_session_uuid"})
    if not task_token:
        return response(400, {"error": "Missing task_token"})
    
    try:
        game_sessions_table.update_item(
            Key = {"uuid": game_session_uuid},
            UpdateExpression = "SET task_token = :task_token",
            ExpressionAttributeValues = {":task_token": task_token}
        )
        logger.info(f"Task token updated successfully")

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return response(500, {"error": str(e)})
    

def response(status_code, body):
    return {"statusCode": status_code, "body": body}