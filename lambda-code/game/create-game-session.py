import json
import boto3
import uuid
import datetime
import logging
import os
import random

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
question_table = dynamodb.Table(f"iu-quiz-questions-{stage}")

def lambda_handler(event, context):
    cors_headers = {
        "Access-Control-Allow-Origin": "https://" + domain,
        "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Credentials": "true"
    }

    try:
        body = json.loads(event["body"])

        created_by = body.get("created_by")
        course_name = body.get("course_name")
        quiz_length = body.get("quiz_length")
        session_uuid = str(uuid.uuid4())

        if not course_name:
            return {"statusCode": 400, "body": json.dumps({"error": "course_name is required"})}
        if not created_by:
            return {"statusCode": 400, "body": json.dumps({"error": "created_by is required"})}
        if not quiz_length:
            return {"statusCode": 400, "body": json.dumps({"error": "quiz_length is required"})}

        try:
            quiz_length = int(quiz_length)
        except ValueError:
            return {"statusCode": 400, "body": json.dumps({"error": "quiz_length must be an integer"})}

        questions = get_public_questions(course_name)
        logger.info("Got questions: %s", questions)

        # Check if questions are less than quiz_length
        if len(questions) < quiz_length:
            return {"statusCode": 400, "body": json.dumps({"error": "Not enough questions for quiz"})}
        
        # Provide random questions for the quiz based on quiz_length
        questions_for_quiz = random.sample(questions, quiz_length)
        logger.info("Questions for quiz: %s", questions_for_quiz)

        item = {
            "uuid": session_uuid,
            "created_by": created_by,
            "created_at": datetime.datetime.now().isoformat(),
            "questions": questions_for_quiz
        }


        table.put_item(Item=item)

        return {
            "statusCode": 200,
            "headers": cors_headers,
            "body": json.dumps({"message": "Session successfully created!", "session_uuid": session_uuid})
        }

    except Exception as e:
        logger.error("Error saving the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": cors_headers,
            "body": json.dumps({"error": str(e)})
        }
    
def get_public_questions(course_name):
    response = question_table.query(
        IndexName="question_visibility_index",
        KeyConditionExpression="#course = :course AND #pub = :public",
        ExpressionAttributeNames={
            "#course": "course",
            "#pub": "public"
        },
        ExpressionAttributeValues={
            ":course": course_name,
            ":public": "true"
        }
    )
    return response.get("Items", [])