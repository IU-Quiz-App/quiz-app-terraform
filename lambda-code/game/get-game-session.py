import json
import boto3
import logging
import os
from decimal import Decimal

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "GET, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

# Function to convert Decimal to float/int
def decimal_converter(obj):
    if isinstance(obj, Decimal):
        return float(obj) if obj % 1 != 0 else int(obj)
    raise TypeError

def lambda_handler(event, context):
    try:
        logger.info("Event: %s", event)

        uuid = event["pathParameters"].get("uuid")

        logger.info("Getting session with uuid: %s", uuid)

        response = table.get_item(
            Key={"uuid": uuid}
        )

        item = response.get('Item')

        logger.info("Got item: %s", item)

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps(item, default=decimal_converter)
        }

    except Exception as e:
        logger.error("Error: %s", str(e))
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }
