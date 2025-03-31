import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(f"iu-quiz-questions-{stage}")


def lambda_handler(event, context):
    cors_headers = {
        "Access-Control-Allow-Origin": "https://" + domain,
        "Access-Control-Allow-Methods": "DELETE, OPTIONS, HEAD",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Credentials": "true"
    }

    try:
        logger.info("Event: %s", event)

        uuid = event["pathParameters"].get("uuid")

        if not uuid:
            raise ValueError("UUID is required")

        logger.info("Deleting question with uuid: %s", uuid)

        response = table.delete_item(
            Key={"uuid": uuid},
            ConditionExpression="attribute_exists(uuid)"
        )

        logger.info("Deleted question: %s", response)

        return {
            "statusCode": 200,
            "headers": cors_headers,
            "body": json.dumps({"message": "Question deleted successfully"})
        }

    except Exception as e:
        logger.error("Error deleting the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": cors_headers,
            "body": json.dumps({"error": str(e)})
        }