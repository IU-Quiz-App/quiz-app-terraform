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


def lambda_handler(event, context):
    cors_headers = {
        "Access-Control-Allow-Origin": "https://" + domain,
        "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Credentials": "true"
    }

    try:
        body = json.loads(event["body"])

        created_by = body.get("created_by")
        session_uuid = str(uuid.uuid4())

        item = {
            "uuid": session_uuid,
            "created_by": created_by,
            "created_at": datetime.datetime.now().isoformat()
        }


        table.put_item(Item=item)

        return {
            "statusCode": 200,
            "headers": cors_headers,
            "body": json.dumps({"message": "Session erfolgreich erstellt!", "session_uuid": session_uuid})
        }

    except Exception as e:
        logger.error("Error saving the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": cors_headers,
            "body": json.dumps({"error": str(e)})
        }