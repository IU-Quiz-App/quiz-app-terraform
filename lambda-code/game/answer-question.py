import json
import boto3
import datetime
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    try:
        body = json.loads(event["body"])

        game_session_uuid = body.get("session_uuid")
        user_uuid = body.get("user_uuid")
        question_uuid = body.get("question_uuid")
        answer = body.get("answer")
        answered_at = datetime.datetime.now().isoformat()

        if not game_session_uuid:
            return {"statusCode": 400, "body": json.dumps({"error": "session_uuid is required"})}
        if not user_uuid:
            return {"statusCode": 400, "body": json.dumps({"error": "user_uuid is required"})}
        if not question_uuid:
            return {"statusCode": 400, "body": json.dumps({"error": "question_uuid is required"})}
        if not answer:
            return {"statusCode": 400, "body": json.dumps({"error": "answer is required"})}

        response = game_answers_table.query(
            IndexName = "game_session_user_question_index",  # Using the new index
            KeyConditionExpression = "game_session_uuid = :game_session_uuid AND user_question = :user_question",
            ExpressionAttributeValues = {
                ":game_session_uuid": game_session_uuid,
                ":user_question": f"{user_uuid}#{question_uuid}"
            }
        )

        user_answer_uuid_items = response.get("Items", [])
        if not user_answer_uuid_items:
            return {"statusCode": 404, "body": json.dumps({"error": "Answer entry not found"})}
        
        user_answer_uuid = user_answer_uuid_items[0]["uuid"]
        
        game_answers_table.update_item(
            Key = {
                "game_session_uuid": game_session_uuid,
                "uuid": user_answer_uuid
            },
            UpdateExpression = "SET answer = :answer, answered_at = :answered_at",
            ExpressionAttributeValues = {":answer": answer, ":answered_at": answered_at}
        )

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Answer successfully saved!"})
        }

    except Exception as e:
        logger.error("Error saving the answer: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }