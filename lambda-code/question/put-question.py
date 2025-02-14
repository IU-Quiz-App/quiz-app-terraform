import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
table = boto3.resource("dynamodb").Table(f"iu-quiz-questions-{stage}")


def lambda_handler(event, context):
    cors_headers = {
        "Access-Control-Allow-Origin": f"https://{domain}",
        "Access-Control-Allow-Methods": "PUT, OPTIONS, HEAD",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Credentials": "true"
    }

    try:
        body = json.loads(event["body"])
        uuid = event["pathParameters"]["uuid"]

        response = table.query(
            IndexName="uuid_index",
            KeyConditionExpression="#uuid = :uuid",
            ExpressionAttributeNames={"#uuid": "uuid"},
            ExpressionAttributeValues={":uuid": uuid}
        )

        if not response.get("Items"):
            raise ValueError(f"No question found for UUID: {uuid}")

        table.update_item(
            Key={"uuid": uuid},
            UpdateExpression="SET course = :course, text = :text, answers = :answers, public = :public, status = :status",
            ExpressionAttributeValues={
                ":course": body["course"], ":text": body["text"], ":answers": body["answers"],
                ":public": str(body.get("public", False)).lower(), ":status": body.get("status", "created")
            }
        )

        return {"statusCode": 200, "headers": cors_headers, "body": json.dumps({"message": "Updated successfully!"})}

    except Exception as e:
        logger.error("Error: %s", str(e), exc_info=True)
        return {"statusCode": 500, "headers": cors_headers, "body": json.dumps({"error": str(e)})}
