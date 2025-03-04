import json
import boto3
import logging
import os
from decimal import Decimal
import random

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
game_sessions_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "GET, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}


def lambda_handler(event, context):
    try:
        logger.info("Event: %s", event)

        game_session_uuid = event["pathParameters"].get("uuid")
        if not game_session_uuid:
            return {"statusCode": 400, "body": json.dumps({"error": "uuid is required"})}

        game_session_item = game_sessions_table.get_item(
            Key={"uuid": game_session_uuid}
        )

        logger.info("Got game session: %s", game_session_item)
        if "Item" not in game_session_item:
            return {"statusCode": 404, "body": json.dumps({"error": "Game session not found"})}

        current_question_index = game_session_item["Item"].get("current_question")

        logger.info("Current question index: %s", current_question_index)

        current_question_index = int(current_question_index)

        next_question_index = current_question_index + 1

        logger.info("Next question index: %s", next_question_index)

        if current_question_index == len(game_session_item["Item"]["questions"]):
            return {
                "statusCode": 200,
                "headers": CORS_HEADERS,
                "body": json.dumps({"info": "End of game"})
            }

        next_question = game_session_item["Item"]["questions"][current_question_index]

        answers = next_question["answers"]

        for answer in answers:
            answer["isTrue"] = False
        random.shuffle(answers)

        next_question["answers"] = answers

        game_sessions_table.update_item(
            Key={"uuid": game_session_uuid},
            UpdateExpression="SET current_question = :next_question_index",
            ExpressionAttributeValues={":next_question_index": next_question_index}
        )

        logger.info("Got question: %s", next_question)

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps(next_question)
        }

    except Exception as e:
        logger.error("Error getting the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }