import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    try:
        body = json.loads(event["body"])

        logger.info("Event: %s", event)

        game_session_uuid = body.get("session_uuid")
        user_uuid = body.get("user_uuid")
        websocket_connection_uuid = event["requestContext"]["connectionId"]

        if not game_session_uuid:
            return {"statusCode": 400, "body": json.dumps({"error": "session_uuid is required"})}
        if not user_uuid:
            return {"statusCode": 400, "body": json.dumps({"error": "user_uuid is required"})}
        
        websocket_connections_table.update_item(
            Key = {"uuid": websocket_connection_uuid},
            UpdateExpression = "SET game_session_uuid = :game_session_uuid, user_uuid = :user_uuid",
            ExpressionAttributeValues = {":game_session_uuid": game_session_uuid, ":user_uuid": user_uuid}
        )

        logger.info(f"Successfully updated websocket connection {websocket_connection_uuid} with game session {game_session_uuid} and user uuid {user_uuid}")

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Answer successfully saved!"})
        }

    except Exception as e:
        logger.error("Error saving the answer: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }