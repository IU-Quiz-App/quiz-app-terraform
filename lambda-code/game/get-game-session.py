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
game_session_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "GET, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    try:
        logger.info("Event: %s", event)

        uuid = event["pathParameters"].get("uuid")

        logger.info("Getting session with uuid: %s", uuid)

        response = game_session_table.get_item(
            Key={"uuid": uuid}
        )

        item = response.get('Item')

        logger.info("Got item: %s", item)

        if item.get("ended_at") or True:
            users = item.get("users")
            users_answers = []
            for user in users:
                answers = get_users_answers(uuid, user)
                users_answers.append({
                    "user": user,
                    "answers": answers
                })

            item["users_answers"] = users_answers


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


# Function to convert Decimal to float/int
def decimal_converter(obj):
    if isinstance(obj, Decimal):
        return float(obj) if obj % 1 != 0 else int(obj)
    raise TypeError

def get_users_answers(game_session_uuid, user_uuid):
    logger.info("Getting answers for user: %s in game session: %s", user_uuid, game_session_uuid)

    response = game_answers_table.query(
        IndexName="user_answers_index",
        KeyConditionExpression="#game_session_uuid = :game_session_uuid AND #user_uuid = :user_uuid",
        ExpressionAttributeNames={
            "#game_session_uuid": "game_session_uuid",
            "#user_uuid": "user_uuid",
        },
        ExpressionAttributeValues={
            ":game_session_uuid": game_session_uuid,
            ":user_uuid": user_uuid,
        }
    )

    logger.info(response)

    return response.get("Items", [])