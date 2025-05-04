import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
dynamodb = boto3.resource("dynamodb")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")

def lambda_handler(event, context):
    try:
        body = json.loads(event["body"])

        logger.info("Event: %s", event)

        game_session_uuid = body.get("session_uuid")
        user_uuid = body.get("user_uuid")
        websocket_connection_uuid = event["requestContext"]["connectionId"]

        if not game_session_uuid:
            logger.error("Missing game_session_uuid")
            return {"statusCode": 400, "body": json.dumps({"error": "session_uuid is required"})}
        if not user_uuid:
            logger.error("Missing user_uuid")
            return {"statusCode": 400, "body": json.dumps({"error": "user_uuid is required"})}
        
        logger.info(f"Updating websocket connection {websocket_connection_uuid} with game session {game_session_uuid} and user uuid {user_uuid}")
        
        websocket_connections_table.update_item(
            Key = {"connection_uuid": websocket_connection_uuid},
            UpdateExpression = "SET game_session_uuid = :game_session_uuid, user_uuid = :user_uuid",
            ExpressionAttributeValues = {":game_session_uuid": game_session_uuid, ":user_uuid": user_uuid}
        )

        logger.info(f"Successfully updated websocket connection {websocket_connection_uuid} with game session {game_session_uuid} and user uuid {user_uuid}")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Answer successfully saved!"})
        }

    except Exception as e:
        logger.error("Error saving the answer: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }