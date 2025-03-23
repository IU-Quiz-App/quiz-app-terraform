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
step_function_arn = os.environ.get('STEP_FUNCTION_ARN')

dynamodb = boto3.resource("dynamodb")
game_session_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
question_table = dynamodb.Table(f"iu-quiz-questions-{stage}")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")

stepfunctions = boto3.client("stepfunctions")
lambda_client = boto3.client("lambda")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    try:
        body = json.loads(event["body"])

        game_session_uuid = body.get("uuid")
        course_name = body.get("course_name")
        quiz_length = body.get("quiz_length")

        if not game_session_uuid:
            return {"statusCode": 400, "body": json.dumps({"error": "uuid of the game session is required"})}
        if not course_name:
            return {"statusCode": 400, "body": json.dumps({"error": "course_name is required"})}
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

        started_at = datetime.datetime.now().isoformat()

        current_question = questions_for_quiz[0]["uuid"]

        # Update the session with the questions and course name
        game_session_table.update_item(
            Key = {"uuid": game_session_uuid},
            UpdateExpression = "SET questions = :questions, course_name = :course_name, started_at = :started_at, current_question = :current_question",
            ExpressionAttributeValues = {
                ":questions": questions_for_quiz, 
                ":course_name": course_name, 
                ":started_at": started_at, 
                ":current_question": 0}
        )

        game_session = game_session_table.query(
            IndexName="uuid_index",
            KeyConditionExpression="#uuid = :question_uuid",
            ExpressionAttributeNames={
                "#uuid": "uuid"
            },
            ExpressionAttributeValues={
                ":question_uuid": game_session_uuid
            }
        )
        logger.info("Got session: %s", game_session)

        users = game_session.get("Items")[0].get("users")
        logger.info("Users: %s", users)

        for question in questions_for_quiz:
            for user in users:
                answers = question["answers"]

                correct_answer = None

                for answer in answers:
                    if answer['isTrue']:
                        correct_answer = answer['uuid']
                        break

                item = {
                    "uuid": str(uuid.uuid4()),
                    "game_session_uuid": game_session_uuid,
                    "question_uuid": question["uuid"],
                    "user_uuid": user,
                    "answer": "",
                    "correct_answer": correct_answer,
                    "timed_out": "",
                    "user_question": f"{user}#{question['uuid']}"
                }
                logger.info("Item: %s", item)
                game_answers_table.put_item(Item=item)

        update_game_session_response = lambda_client.invoke(
            FunctionName=f"send_updated_game_session_{stage}",
            InvocationType="Event",
            Payload=json.dumps({"game_session_uuid": game_session_uuid})
        )

        logger.info(f"Update game session lambda invoked: {update_game_session_response}")

        response = stepfunctions.start_execution(
            stateMachineArn=step_function_arn,
            input=json.dumps({
                "game_session_uuid": game_session_uuid,
                "quiz_length": quiz_length,
            })
        )

        logger.info(f"Step function started: {response}")

        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": json.dumps({"message": "Game started!", "session_uuid": game_session_uuid})
        }

    except Exception as e:
        logger.error("Error saving the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
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