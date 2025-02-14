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

        old_item = response["Items"][0]
        old_course = old_item["course"]

        new_course = body.get("course", old_course)
        updated_item = {
            "course": new_course,
            "uuid": old_item["uuid"],
            "text": body.get("text", old_item["text"]),
            "answers": body.get("answers", old_item["answers"]),
            "public": str(body.get("public", old_item["public"])).lower(),
            "status": body.get("status", old_item["status"]),
            "created_at": old_item["created_at"],
            "created_by": old_item["created_by"]
        }

        table.put_item(Item=updated_item)

        if new_course != old_course:
            table.delete_item(Key={"course": old_course, "uuid": uuid})

        return {"statusCode": 200,
                "headers": cors_headers,
                "body": json.dumps({
                    "message": "Updated successfully!",
                    "question": updated_item
                })
        }

    except Exception as e:
        logger.error("Error: %s", str(e), exc_info=True)
        return {"statusCode": 500, "headers": cors_headers, "body": json.dumps({"error": str(e)})}
