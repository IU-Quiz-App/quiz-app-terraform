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
table = dynamodb.Table(f"iu-quiz-questions-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    try:
        body = json.loads(event["body"])

        for answer in body["answers"]:
            answer["uuid"] = str(uuid.uuid4())

        item = {
            "course": body["course"],
            "uuid": str(uuid.uuid4()),
            "text": body["text"],
            "answers": body["answers"],
            "created_by": body["created_by"],
            "public": "true" if body.get("public", False) else "false",
            "status": body.get("status", "created"),
            "created_at": datetime.datetime.now().isoformat()
        }

        logger.info("Question item written to the database: %s", json.dumps(item, indent=2))

        table.put_item(Item=item)
        
        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Frage erfolgreich gespeichert!", "question": item})
        }
    
    except Exception as e:
        logger.error("Error saving the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }