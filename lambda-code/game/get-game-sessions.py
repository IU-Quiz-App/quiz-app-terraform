import json
import boto3
import logging
import os
from decimal import Decimal
import base64

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
user_game_sessions_table = dynamodb.Table(f"iu-quiz-user-game-sessions-{stage}")
lambda_client = boto3.client("lambda")

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



        response = get_users_sessions(user_id, page, page_size)

        logger.info("Got sessions: %s", response)
        items = response.get("items", [])



        total_items = response.get("total_count", 0)

        game_sessions = []

        for item in items:
            try:
                game_session_uuid = item.get("game_session_uuid")
                if not game_session_uuid:
                    logger.error("Game session uuid not found in item: %s", item)
                    continue

                result = lambda_client.invoke(
                    FunctionName=f"get_game_session_{stage}",
                    InvocationType="RequestResponse",
                    Payload=json.dumps({"pathParameters": {"uuid": game_session_uuid}})
                )

                logger.info(f"Payload: {result}")
                body = json.loads(result["Payload"].read()).get("body")
                game_session_item = json.loads(body)

                if not game_session_item:
                    logger.error("Game session with uuid %s not found", game_session_uuid)
                    continue

                game_sessions.append(game_session_item)
            except Exception as e:
                logger.error("Error getting game session: %s", str(e), exc_info=True)
                continue

        logger.info("Got items: %s", items)

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({
                "items": game_sessions,
                "total_items": total_items
            }, default=decimal_converter)
        }

    except Exception as e:
        logger.error("Error getting the sessions: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }

def decimal_converter(obj):
    if isinstance(obj, Decimal):
        return float(obj) if obj % 1 != 0 else int(obj)
    raise TypeError

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

def http_response(status_code, body):
    return {"statusCode": status_code, "headers": CORS_HEADERS, "body": json.dumps(body)}

def get_users_sessions(user_uuid, page, page_size):
    try:
        # Perform a Scan operation to retrieve all items
        response = user_game_sessions_table.scan()
        all_items = response.get("Items", [])

        # Handle pagination if LastEvaluatedKey exists
        while "LastEvaluatedKey" in response:
            response = user_game_sessions_table.scan(
                ExclusiveStartKey=response["LastEvaluatedKey"]
            )
            all_items.extend(response.get("Items", []))

        # Filter items to include only those with started_at and matching user_uuid
        filtered_items = [
            item for item in all_items
            if "started_at" in item and item.get("user_uuid") == user_uuid
        ]

        # Calculate total count
        total_count = len(filtered_items)

        # Calculate start and end indices for pagination
        start_index = (page - 1) * page_size
        end_index = start_index + page_size

        # Return the paginated results and total count
        return {
            "items": filtered_items[start_index:end_index],
            "total_count": total_count
        }

    except Exception as e:
        logger.error("Error fetching started sessions: %s", str(e), exc_info=True)
        return {"items": [], "total_count": 0}