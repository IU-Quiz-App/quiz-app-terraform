import json
import os
import logging
import boto3
import datetime
from decimal import Decimal

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
websocket_wss_api_endpoint = os.environ.get('WEBSOCKET_API_GATEWAY_ENDPOINT')
websocket_api_endpoint = f"{websocket_wss_api_endpoint.replace('wss', 'https')}/{stage}"

dynamodb = boto3.resource("dynamodb")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")
game_sessions_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")

apigateway_management = boto3.client(
    "apigatewaymanagementapi",
    endpoint_url=websocket_api_endpoint
)

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    game_session_uuid = event.get("game_session_uuid")
    current_question_index = event.get("current_question_index")
    action_type = event.get("action_type")
    wait_seconds = event.get("wait_seconds")

    if not game_session_uuid:
        logger.error("Missing game_session_uuid")
        raise ValueError("Missing game_session_uuid")
    if current_question_index is None:
        logger.error("Missing current_question_index")
        raise ValueError("Missing current_question_index")
    if not action_type:
        logger.error("Missing action_type")
        raise ValueError("Missing action_type")
    if not wait_seconds:
        logger.error("Missing wait_seconds")
        raise ValueError("Missing wait_seconds")
    
    try:    
        game_session_item = get_game_session(game_session_uuid)
        if not game_session_item:
            logger.error("Game session not found")
            raise ValueError("Game session not found")
        
        question = get_question(game_session_item, current_question_index, action_type)

        if action_type == "next-question":
            sended_at = datetime.datetime.now().isoformat()
            update_game_session(game_session_uuid, current_question_index, sended_at)
        else:
            users_answers = get_all_answers_of_question(game_session_item["uuid"], question["uuid"])
            users_answers = save_question_scores(game_session_item, question, users_answers)

            timed_out_answers = [ua for ua in users_answers if ua["timed_out"] == "true"]
            question["timed_out_answers"] = timed_out_answers

            answers = []
            for answer in question.get("answers", []):
                answer["user_answers"] = [ua for ua in users_answers if ua["answer"] == answer["uuid"]]
                answers.append(answer)

            question["answers"] = answers

        send_question_to_all_players(game_session_uuid, question, action_type, wait_seconds)
        logger.info(f"Question sent to all players: {question}")
        question_uuid = question["uuid"]
        logger.info(f"Question uuid: {question_uuid}")
        return response(200, {"message": "Question sent to all players", "current_question_uuid": question_uuid})
    
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return response(500, {"error": str(e)})

def get_game_session(game_session_uuid):
    response = game_sessions_table.get_item(Key={"uuid": game_session_uuid})
    return response.get("Item")

def get_question(game_session_item, question_index, action_type):
    question = game_session_item["questions"][question_index]

    if action_type == "next-question":
        # Set all answers to false to prevent cheating
        answers = question["answers"]
        for answer in answers:
            answer["isTrue"] = False
            answer["explanation"] = ''
        question["answers"] = answers

    logger.info(f"Question with shuffled answers: {question}")
    return question

def save_question_scores(game_session, question, user_answers):
    try:
        question_response_time = game_session.get("question_response_time", 0)

        new_user_answers = []

        answers = question.get("answers", [])
        logger.info(f"Answers: {answers}")

        correct_answer = next((answer for answer in answers if answer.get("isTrue")), None)
        logger.info(f"Correct answer: {correct_answer}")
        if not correct_answer:
            logger.error(f"No correct answer found for question {question['uuid']}")
            return

        question_user_answers = [
            ua for ua in user_answers if ua["answer"] == correct_answer["uuid"]
        ]

        # sort after answered_at
        question_user_answers.sort(key=lambda x: x["answered_at"])

        question_sended_at = datetime.datetime.fromisoformat(question["sended_at"])
        question_response_time_millis = question_response_time * 1000

        for i, answer in enumerate(question_user_answers):
            base_score = 300

            if i == 0:
                bonus_score = 300
            elif i == 1:
                bonus_score = 200
            elif i == 2:
                bonus_score = 100
            else:
                bonus_score = 0

            logger.info(f"Bonus score: {bonus_score}")

            time_base_score = 400
            answered_at = datetime.datetime.fromisoformat(answer["answered_at"])
            logger.info(f"Answered at: {answered_at}")

            delta = answered_at - question_sended_at
            delta_millis = (delta.total_seconds() * 1000) - 1000
            logger.info(f"Delta millis: {delta_millis}")

            time_left = question_response_time_millis - Decimal(delta_millis)
            if time_left < 0:
                time_left = 0
            if time_left > question_response_time_millis:
                time_left = question_response_time_millis

            logger.info(f"Time left: {time_left}")
            time_score_factor = Decimal(time_left) / Decimal(question_response_time_millis)
            time_score = int(time_base_score * time_score_factor)
            logger.info(f"Time score: {time_score}")
            score = base_score + bonus_score + time_score
            logger.info(f"Score: {score}")

            answer["score"] = score
            new_user_answers.append(answer)


        wrong_user_answers = [ua for ua in user_answers if ua["answer"] != correct_answer["uuid"]]

        #append to new_user_answers
        for answer in wrong_user_answers:
            answer["score"] = 0
            new_user_answers.append(answer)

        # save new user answers
        for answer in new_user_answers:
            game_answers_table.update_item(
                Key={
                    "game_session_uuid": game_session["uuid"],
                    "uuid": answer["uuid"]
                },
                UpdateExpression="SET #score = :score",
                ExpressionAttributeNames={
                    "#score": "score"
                },
                ExpressionAttributeValues={
                    ":score": answer["score"]
                }
            )

        logger.info(f"Saved user answers: {new_user_answers}")

        return new_user_answers

    except Exception as e:
        logger.error(f"Error saving game session scores: {str(e)}", exc_info=True)

def update_game_session(game_session_uuid, question_index, sended_at):
    game_sessions_table.update_item(
        Key={"uuid": game_session_uuid},
        UpdateExpression=f"SET #questions[{question_index}].#sended_at = :sended_at",
        ExpressionAttributeValues={":sended_at": sended_at},
        ConditionExpression="attribute_exists(#uuid)",
        ExpressionAttributeNames={
            "#uuid": "uuid",
            "#questions": "questions",
            "#sended_at": "sended_at"
        }
    )

    logger.info(f"Game session {game_session_uuid} updated sended_at to {sended_at} for question index {question_index}")

def send_question_to_all_players(game_session_uuid, question, action_type, wait_seconds):
    logger.info(f"Sending question to all clients in session: {game_session_uuid}")
    response = websocket_connections_table.scan(
        FilterExpression="game_session_uuid = :session",
        ExpressionAttributeValues={":session": game_session_uuid}
    )

    connections = response.get("Items", [])

    logger.info(f"Found {len(connections)} connections for session {game_session_uuid}: {connections}")

    for connection in connections:
        connection_id = connection["connection_uuid"]
        try:
            apigateway_management.post_to_connection(
                ConnectionId=connection_id,
                Data=json.dumps({
                    "action": action_type,
                    "question": question,
                    "wait_seconds": wait_seconds
                })
            )
            logger.info(f"Sent question to {connection_id}")

        except apigateway_management.exceptions.GoneException:
            logger.info(f"Connection {connection_id} is gone")

def response(status_code, body):
    return {"statusCode": status_code, "body": body}

def get_all_answers_of_question(game_session_uuid, question_uuid):
    try:
        response = game_answers_table.query(
            IndexName="game_session_question_index",
            KeyConditionExpression="#game_session_uuid = :game_session_uuid AND #question_uuid = :question_uuid",
            ExpressionAttributeNames={
                "#game_session_uuid": "game_session_uuid",
                "#question_uuid": "question_uuid"
            },
            ExpressionAttributeValues={
                ":game_session_uuid": game_session_uuid,
                ":question_uuid": question_uuid
            }
        )
        return response.get("Items", [])
    except Exception as e:
        logger.error(f"Error retrieving answers for question {question_uuid}: {str(e)}", exc_info=True)
        return []