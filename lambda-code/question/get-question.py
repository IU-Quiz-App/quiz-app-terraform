import json
import boto3
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

        if "uuid" not in body:
            raise ValueError("UUID is required")
        uuid = body["uuid"]

        logger.info("Getting question with uuid: %s", uuid)

        item = {
           "uuid": body["uuid"]
        }
        response = table.get_item(Key=item)

        return {
            "statusCode": 200,
            "body": json.dumps(response)
        }

    except Exception as e:
        logger.error("Error getting the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }