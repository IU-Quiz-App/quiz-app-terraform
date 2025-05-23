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

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "DELETE, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    try:
        logger.info("Event: %s", event)

        uuid = event["pathParameters"].get("uuid")
        course = event["queryStringParameters"].get("course")

        if not uuid:
            raise ValueError("UUID is required")
        if not course:
            raise ValueError("Course is required")

        logger.info("Deleting question with uuid: %s", uuid)

        item = table.get_item(
            Key={"uuid": uuid, "course": course},
        )

        if "Item" not in item:
            raise ValueError(f"No question found for UUID: {uuid}")

        response = table.delete_item(
            Key={"uuid": uuid, "course": course},
            ConditionExpression="attribute_exists(#uuid)",
            ExpressionAttributeNames={"#uuid": "uuid"}
        )

        logger.info("Deleted question: %s", response)

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Question deleted successfully"})
        }

    except Exception as e:
        logger.error("Error deleting the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }