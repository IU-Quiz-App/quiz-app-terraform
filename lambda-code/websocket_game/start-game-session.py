import json
import boto3
import uuid
import datetime
import logging
import os
import random
import base64

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
step_function_arn = os.environ.get('STEP_FUNCTION_ARN')
websocket_wss_api_endpoint = os.environ.get('WEBSOCKET_API_GATEWAY_ENDPOINT')
websocket_api_endpoint = f"{websocket_wss_api_endpoint.replace('wss', 'https')}/{stage}"

dynamodb = boto3.resource("dynamodb")
game_session_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
user_game_sessions_table = dynamodb.Table(f"iu-quiz-user-game-sessions-{stage}")
question_table = dynamodb.Table(f"iu-quiz-questions-{stage}")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")

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

    connection_id = event["requestContext"]["connectionId"]
    connection = get_websocket_connection(connection_id)

    if not connection:
        logger.error(f"Connection {connection_id} not found")
        return ws_response(connection_id, {"error": "Connection not found"})

    token = connection.get("access_token")
    if not token:
        logger.error("Missing access_token")
        return ws_response(connection_id, {"error": "Missing access_token"})

    jwt_payload = decode_jwt_payload(token)
    if not jwt_payload:
        logger.error("Invalid JWT payload")
        return ws_response(connection_id, {"error": "Invalid Token"})

    default_response_time = 5

    game_session_uuid = body.get("game_session_uuid")
    course_name = body.get("course_name")
    quiz_length = body.get("quiz_length")
    question_response_time = body.get("question_response_time", default_response_time)

    if not game_session_uuid:
        logger.error("Missing game_session_uuid")
        ws_response(connection_id, {"error": "Missing game_session_uuid"})
        return
    if not course_name:
        logger.error("Missing course_name")
        ws_response(connection_id, {"error": "Missing course_name"})
        return
    if not quiz_length:
        logger.error("Missing quiz_length")
        ws_response(connection_id, {"error": "Missing quiz_length"})
        return
    if "question_response_time" not in body:
        logger.error(f"Missing question_response_time, set to default {default_response_time}")
        ws_response(connection_id, {"error": f"Missing question_response_time, set to default {default_response_time}"})
        
    try:
        quiz_length = int(quiz_length)
    except ValueError:
        logger.error("quiz_length must be an integer")
        ws_response(connection_id, {"error": "quiz_length must be an integer"})
        return

    try:
        user_uuid = jwt_payload.get("oid")
        logger.info(f"user_uuid: {user_uuid}")

        response = game_session_table.query(
            IndexName="uuid_index",
            KeyConditionExpression="#uuid = :question_uuid",
            ExpressionAttributeNames={
                "#uuid": "uuid"
            },
            ExpressionAttributeValues={
                ":question_uuid": game_session_uuid
            }
        )

        game_session = response.get("Items")[0]
        logger.info("Got session: %s", game_session)

        created_by = game_session.get('created_by')
        logger.info(f"created_by: {created_by}")
        if (created_by != user_uuid):
            logger.error("User not authorized to start this game session")
            ws_response(connection_id, {"error": "User not authorized to start this game session"})
            return

        questions = get_public_questions(course_name)
        logger.info("Got questions: %s", questions)

        # Check if questions are less than quiz_length
        if len(questions) < quiz_length:
            ws_response(connection_id, {"action": "not-enough-questions"})
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

        update_user_game_sessions(game_session_uuid, started_at)

        users = game_session.get("users")
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
                    "user_uuid": user["user_uuid"],
                    "answer": "",
                    "correct_answer": correct_answer,
                    "timed_out": "",
                    "user_question": f"{user["user_uuid"]}#{question['uuid']}"
                }
                logger.info("Item: %s", item)
                game_answers_table.put_item(Item=item)

        update_game_session_response = lambda_client.invoke(
            FunctionName=f"send_updated_game_session_{stage}",
            InvocationType="Event",
            Payload=json.dumps({
                "game_session_uuid": game_session_uuid,
                "update_reason": "start-game",
            })
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

    except Exception as e:
        logger.error("Error starting the session: %s", str(e), exc_info=True)
    
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

def ws_response(connection_id, data):
    logger.info(f"Sending response to connection {connection_id}: {data}")
    try:
        response = apigateway_management.post_to_connection(
            ConnectionId=connection_id,
            Data=json.dumps(data)
        )
        logger.info(f"Response: {response}")
        logger.info(f"Response sent to connection {connection_id}")
    except Exception as e:
        logger.error(f"Error sending response: {str(e)}")

def get_websocket_connection(connection_id):
    try:
        response = websocket_connections_table.get_item(
            Key={
                "connection_uuid": connection_id
            }
        )
        return response.get("Item")
    except Exception as e:
        logger.error(f"Error getting websocket connection: {str(e)}")
        return None


def update_user_game_sessions(game_session_uuid, started_at):
    try:
        # Query the table to get all items with the specified game_session_uuid
        response = user_game_sessions_table.query(
            KeyConditionExpression="#game_session_uuid = :game_session_uuid",
            ExpressionAttributeNames={
                "#game_session_uuid": "game_session_uuid"
            },
            ExpressionAttributeValues={
                ":game_session_uuid": game_session_uuid
            }
        )
        items = response.get("Items", [])

        # Update each item with the started_at attribute
        for item in items:
            user_uuid = item["user_uuid"]
            user_game_sessions_table.update_item(
                Key={"user_uuid": user_uuid, "game_session_uuid": game_session_uuid},
                UpdateExpression="SET started_at = :started_at",
                ExpressionAttributeValues={":started_at": started_at}
            )
            logger.info(f"Updated item: {game_session_uuid} for user: {user_uuid} with started_at: {started_at}")

    except Exception as e:
        logger.error(f"Error updating user game sessions: {str(e)}", exc_info=True)