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
step_function_arn = os.environ.get('STEP_FUNCTION_ARN')
websocket_wss_api_endpoint = os.environ.get('WEBSOCKET_API_GATEWAY_ENDPOINT')
websocket_api_endpoint = f"{websocket_wss_api_endpoint.replace('wss', 'https')}/{stage}"

dynamodb = boto3.resource("dynamodb")
game_session_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
question_table = dynamodb.Table(f"iu-quiz-questions-{stage}")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")

stepfunctions = boto3.client("stepfunctions")
lambda_client = boto3.client("lambda")

apigateway_management = boto3.client(
    "apigatewaymanagementapi",
    endpoint_url=websocket_api_endpoint
)

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")
    body = json.loads(event["body"])

    logger.info(f"websocket_api_endpoint: {websocket_api_endpoint}")

    default_response_time = 5

    connection_id = event["requestContext"]["connectionId"]

    game_session_uuid = body.get("game_session_uuid")
    course_name = body.get("course_name")
    quiz_length = body.get("quiz_length")
    question_response_time = body.get("question_response_time", default_response_time)

    if not game_session_uuid:
        logger.error("Missing game_session_uuid")
        send_error_response(connection_id, "Missing game_session_uuid")
        return
    if not course_name:
        logger.error("Missing course_name")
        send_error_response(connection_id, "Missing course_name")
        return
    if not quiz_length:
        logger.error("Missing quiz_length")
        send_error_response(connection_id, "Missing quiz_length")
        return
    if "question_response_time" not in body:
        logger.error(f"Missing question_response_time, set to default {default_response_time}")
        send_error_response(connection_id, f"Missing question_response_time, set to default {default_response_time}")
        
    try:
        quiz_length = int(quiz_length)
    except ValueError:
        logger.error("quiz_length must be an integer")
        send_error_response(connection_id, "quiz_length must be an integer")
        return

    try:

        questions = get_public_questions(course_name)
        logger.info("Got questions: %s", questions)

        # Check if questions are less than quiz_length
        if len(questions) < quiz_length:
            logger.error(f"Not enough questions available for quiz length {quiz_length}")
            send_error_response(connection_id, f"Not enough questions available for quiz length {quiz_length}")
            return
        
        # Provide random questions for the quiz based on quiz_length
        questions_for_quiz = random.sample(questions, quiz_length)

        shuffled_questions = []

        for question in questions_for_quiz:
            answers = question["answers"]
            random.shuffle(answers)
            question["answers"] = answers
            shuffled_questions.append(question)

        logger.info("Questions for quiz: %s", questions_for_quiz)

        started_at = datetime.datetime.now().isoformat()


        # Update the session with the questions and course name
        game_session_table.update_item(
            Key = {"uuid": game_session_uuid},
            UpdateExpression = "SET questions = :questions, course_name = :course_name, started_at = :started_at, current_question = :current_question",
            ExpressionAttributeValues = {
                ":questions": shuffled_questions,
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
                "question_response_time": question_response_time,
            })
        )

        logger.info(f"Step function started: {response}")

        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Game started!", "session_uuid": game_session_uuid})
        }

    except Exception as e:
        logger.error("Error saving the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
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

def send_error_response(connection_id, error_message):
    logger.info(f"Sending error response to connection {connection_id}: {error_message}")
    try:
        response = apigateway_management.post_to_connection(
            ConnectionId=connection_id,
            Data=json.dumps({
                "error": error_message
            })
        )
        logger.info(f"Response: {response}")
        logger.info(f"Error response sent to connection {connection_id}")
    except Exception as e:
        logger.error(f"Error sending error response: {str(e)}")