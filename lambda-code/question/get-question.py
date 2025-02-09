import json
import boto3
import datetime
import logging
import os
from botocore.exceptions import ClientError

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get("STAGE")
dynamodb = boto3.resource("dynamodb")
table_name = f"iu-quiz-questions-{stage}"
table = dynamodb.Table(table_name)


def get_table_schema():
    """Fetch the table schema from DynamoDB"""
    dynamodb_client = boto3.client("dynamodb")
    try:
        response = dynamodb_client.describe_table(TableName=table_name)
        key_schema = response["Table"]["KeySchema"]
        return key_schema
    except Exception as e:
        logger.error("Failed to fetch table schema: %s", str(e), exc_info=True)
        return None


def lambda_handler(event, context):
    try:
        body = json.loads(event.get("body", "{}"))

        if "uuid" not in body:
            raise ValueError("UUID is required")
        uuid = body["uuid"]

        logger.info("Getting question with uuid: %s", uuid)

        item = table.get_item(Key={"uuid": uuid}).get("Item")
        if not item:
            raise ValueError("Question not found")

        return {
            "statusCode": 200,
            "body": json.dumps(item),
        }

    except ClientError as e:
        if e.response["Error"]["Code"] == "ValidationException":
            schema = get_table_schema()
            return {
                "statusCode": 400,
                "body": json.dumps(
                    {
                        "error": "ValidationException",
                        "message": e.response["Error"]["Message"],
                        "expected_schema": schema,
                    }
                ),
            }

        logger.error("DynamoDB error: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }

    except Exception as e:
        logger.error("Error getting the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)}),
        }
