import json
import boto3
import logging
import os
import base64

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(f"iu-quiz-questions-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "GET, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    try:
        logger.info("Event: %s", event)

        token = event["headers"].get("authorization", "")
        payload = decode_jwt_payload(token)

        if not payload:
            return http_response(401, {"error": "Invalid Token"})

        user_id = payload.get("oid")

        if not user_id:
            return http_response(400, {"error": "Invalid Token: Missing oid"})

        page = int(event["queryStringParameters"].get("page", 1))
        page_size = int(event["queryStringParameters"].get("page_size", 10))

        # Query to get the total count of all matching items
        total_count_response = table.query(
            IndexName="user_questions_index",
            KeyConditionExpression="#created_by = :user_id",
            ExpressionAttributeNames={
                "#created_by": "created_by"
            },
            ExpressionAttributeValues={
                ":user_id": user_id
            },
            Select="COUNT"
        )
        total_items = total_count_response.get("Count", 0)

        # Query to get the paginated items
        query_params = {
            "IndexName": "user_questions_index",
            "KeyConditionExpression": "#created_by = :user_id",
            "ExpressionAttributeNames": {
                "#created_by": "created_by"
            },
            "ExpressionAttributeValues": {
                ":user_id": user_id
            },
            "Limit": page_size
        }

        if page > 1:
            for _ in range(page - 1):
                response = table.query(**query_params)
                start_key = response.get("LastEvaluatedKey")
                if not start_key:
                    break
                query_params["ExclusiveStartKey"] = start_key

        response = table.query(**query_params)

        logger.info("Got questions: %s", response)

        items = response.get("Items")

        logger.info("Got items: %s", items)

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({
                "items": items,
                "total_items": total_items
            })
        }

    except Exception as e:
        logger.error("Error getting the questions: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }


def http_response(status_code, body):
    return {"statusCode": status_code, "headers": CORS_HEADERS, "body": json.dumps(body)}

def decode_jwt_payload(token):
    token = token.replace("Bearer ", "")
    try:
        parts = token.split('.')
        if len(parts) != 3:
            raise ValueError("Invalid JWT format")

        payload_b64 = parts[1]
        padding = '=' * (-len(payload_b64) % 4)
        payload_b64 += padding

        payload_bytes = base64.urlsafe_b64decode(payload_b64)
        payload = json.loads(payload_bytes)

        return payload

    except Exception as e:
        logger.error("Failed to decode JWT payload: %s", str(e))
        return None