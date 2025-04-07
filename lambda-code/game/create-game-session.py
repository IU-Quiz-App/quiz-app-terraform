import json
import boto3
import uuid
import datetime
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    try:
        body = json.loads(event["body"])
        headers = event["headers"]

        token = headers.get("authorization")
        if not token:
            return {"statusCode": 401, "body": json.dumps({"error": "Unauthorized"})}
        logger.info(f"Token: {token}")

        created_by = body.get("created_by")
        session_uuid = str(uuid.uuid4())

        if not created_by:
            return {"statusCode": 400, "body": json.dumps({"error": "created_by is required"})}

        item = {
            "uuid": session_uuid,
            "created_by": created_by,
            "created_at": datetime.datetime.now().isoformat(),
            "users": ["Philipp", "Jannis", "Janna"]
        }

        table.put_item(Item=item)

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Session successfully created!", "session": item})
        }

    except Exception as e:
        logger.error("Error creating session: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }