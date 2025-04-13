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

        game_session = response.get('Item')

        logger.info("Got item: %s", game_session)

        if game_session.get("ended_at"):
            users_answers = get_all_answers_of_session(uuid)
            logger.info("Got answers: %s", users_answers)

            questions = []

            for question in game_session.get("questions", []):
                logger.info("Getting answers for question: %s", question)
                answers = []
                for answer in question.get("answers", []):
                    logger.info("Getting answers for answer: %s", answer)
                    answer["user_answers"] = [ua for ua in users_answers if ua["answer"] == answer["uuid"] and ua["question_uuid"] == question["uuid"]]
                    answers.append(answer)
                question["answers"] = answers
                logger.info("Got answers for question: %s", question)
                question['timed_out_answers'] = [ua for ua in users_answers if ua["question_uuid"] == question["uuid"] and ua["timed_out"] == "true"]
                questions.append(question)
            game_session["questions"] = questions


        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps(game_session, default=decimal_converter)
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

def get_all_answers_of_session(game_session_uuid):
    try:
        response = game_answers_table.query(
            KeyConditionExpression="#game_session_uuid = :game_session_uuid",
            ExpressionAttributeNames={
                "#game_session_uuid": "game_session_uuid"
            },
            ExpressionAttributeValues={
                ":game_session_uuid": game_session_uuid
            }
        )
        return response.get("Items", [])
    except Exception as e:
        logger.error("Error retrieving answers: %s", str(e))
        return []