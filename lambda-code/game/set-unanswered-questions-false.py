import json
import os
import logging
import boto3

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
dynamodb = boto3.resource("dynamodb")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    game_session_uuid = event.get("game_session_uuid")
    question_uuid = event.get("current_question_uuid")

    if not game_session_uuid:
        return response(400, {"error": "Missing game_session_uuid"})
    if not question_uuid:
        return response(400, {"error": "Missing question_uuid"})
    
    try:
        player_answers = get_player_answers(game_session_uuid, question_uuid)
        if not player_answers:
            return response(404, {"error": "No player answers found"})
        
        player_answer_missing = False
        for player_answer in player_answers:
            if not player_answer.get("answer"):
                player_answer_missing = True
                game_answers_table.update_item(
                    Key = {
                        "game_session_uuid": game_session_uuid,
                        "uuid": player_answer["uuid"]
                    },
                    UpdateExpression = "SET timed_out = :timed_out",
                    ExpressionAttributeValues = {":timed_out": "true"}
                )
                logger.info(f"Question {player_answer["question_uuid"]} of player {player_answer["user_uuid"]} set to false because of timeout")
        if player_answer_missing:
            return response(200, {"message": "Unanswered questions set to false"})
        else:
            return response(200, {"message": "All answers were complete"})
                    
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return response(500, {"error": str(e)})

def get_player_answers(game_session_uuid, question_uuid):
    player_answers = game_answers_table.query(
            IndexName="game_session_question_index",
            KeyConditionExpression="game_session_uuid = :game_session_uuid AND question_uuid = :question_uuid",
            ExpressionAttributeValues={
                ":game_session_uuid": game_session_uuid,
                ":question_uuid": question_uuid
            }
        )
    logger.info(f"Player answers: {player_answers["Items"]}")
    return player_answers["Items"]

def response(status_code, body):
    return {"statusCode": status_code, "body": body}