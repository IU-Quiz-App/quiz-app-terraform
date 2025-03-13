import json
import boto3
import datetime
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
dynamodb = boto3.resource("dynamodb")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")
game_sessions_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")
    body = json.loads(event["body"])

    game_session_uuid = body.get("game_session_uuid")
    user_uuid = body.get("user_uuid")
    question_uuid = body.get("question_uuid")
    answer = body.get("answer")
    answered_at = datetime.datetime.now().isoformat()

    if not game_session_uuid:
        return response(400, {"error": "Missing game_session_uuid"})
    if not user_uuid:
        return response(400, {"error": "Missing user_uuid"})
    if not question_uuid:
        return response(400, {"error": "Missing question_uuid"})
    if not answer:
        return response(400, {"error": "Missing answer"})
    
    try:
        player_answers = get_player_answers(game_session_uuid, question_uuid)
        if not player_answers:
            return response(404, {"error": "No player answers found"})
        
        # Update the answer of the player
        for player_answer in player_answers:
            if player_answer["user_uuid"] == user_uuid:
                game_answers_table.update_item(
                    Key = {
                        "game_session_uuid": game_session_uuid,
                        "uuid": player_answer["uuid"]
                    },
                    UpdateExpression = "SET answer = :answer, answered_at = :answered_at",
                    ExpressionAttributeValues = {":answer": answer, ":answered_at": answered_at}
                )
                logger.info(f"Answer of user {user_uuid} updated successfully")

        # Check if all players have answered
        player_answers = get_player_answers(game_session_uuid, question_uuid)
        all_players_answered = True
        for player_answer in player_answers:
            if not player_answer.get("answer"):
                all_players_answered = False
                break

        # Send success token to step function if all players have answered
        if all_players_answered:
            game_session = game_sessions_table.get_item(Key={"uuid": game_session_uuid}).get("Item")
            task_token = game_session.get("task_token")
            logger.info(f"Task token: {task_token}")
#            task_token = game_sessions_table.get_item(Key={"uuid": game_session_uuid}, ProjectionExpression="task_token")
#            logger.info(f"Task token: {task_token}")
            if not task_token:
                return response(404, {"error": "Task token not found"})
            
            stepfunctions = boto3.client("stepfunctions")
            stepfunctions.send_task_success(
                taskToken=task_token,
                output=json.dumps({"message": "All players have answered"})
            )
            logger.info(f"Task success sent to step function")

        return response(200, {"message": "Answer saved successfully"})



        

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