import json
import boto3
import uuid
import datetime
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
    "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    try:
        token = event["headers"].get("authorization", "")
        payload = decode_jwt_payload(token)

        if not payload:
            return http_response(401, {"error": "Invalid Token"})

        user_id = payload.get("oid")

        if not user_id:
            return http_response(400, {"error": "Invalid Token: Missing oid"})

        body = json.loads(event["body"])

        for item in body["items"]:
            try:
                for answer in item["answers"]:
                    answer["uuid"] = str(uuid.uuid4())

                item = {
                    "course": item["course"],
                    "uuid": str(uuid.uuid4()),
                    "text": item["text"],
                    "answers": item["answers"],
                    "created_by": user_id,
                    "public": "true" if item.get("public", False) else "false",
                    "status": item.get("status", "created"),
                    "created_at": datetime.datetime.now().isoformat()
                }

                logger.info("Question item written to the database: %s", json.dumps(item, indent=2))

                table.put_item(Item=item)

            except Exception as e:
                logger.error("Error saving question item: %s", str(e))
                continue

        
        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Erfolgreich gespeichert!"})
        }
    
    except Exception as e:
        logger.error("Error saving the question: %s", str(e), exc_info=True)
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