import json
import boto3
import uuid
import datetime
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(f"iu-quiz-questions-{stage}")

def lambda_handler(event, context):
    
    try:
        body = json.loads(event["body"])

        for answer in body["answers"]:
            answer["uuid"] = str(uuid.uuid4())
        #TODO: Use 1, 2, 3, 4 for answer IDs instead of uuids?

        item = {
            "course": body["course"],
            "question_id": str(uuid.uuid4()),
            "text": body["text"],
            "answers": body["answers"],
            "creator_user_id": body["creator_user_id"],
            "visibility": body.get("visibility", "private"),
            "status": body.get("status", "created"),
            "created_at": datetime.datetime.now().isoformat()
        }

        logger.info("Question item written to the database: %s", json.dumps(item, indent=2))

        table.put_item(Item=item)
        
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Frage erfolgreich gespeichert!", "question_id": item["question_id"]})
        }
    
    except Exception as e:
        logger.error("Error saving the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }