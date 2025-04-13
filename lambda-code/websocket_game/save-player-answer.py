import json
import boto3
import datetime
import logging
import os
import base64

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
dynamodb = boto3.resource("dynamodb")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")
game_sessions_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    connection_uuid = event["requestContext"]["connectionId"]
    connection = get_websocket_connection(connection_uuid)

    if not connection:
        logger.error(f"Connection {connection_uuid} not found")
        return ws_response(400, {"error": "Connection not found"})

    token = connection.get("access_token")
    if not token:
        logger.error("Missing access_token")
        return ws_response(401, {"error": "Missing access_token"})

    jwt_payload = decode_jwt_payload(token)
    if not jwt_payload:
        logger.error("Invalid Token")
        return ws_response(401, {"error": "Invalid Token"})

    user_uuid = jwt_payload.get("oid")

    if not user_uuid:
        logger.error("Invalid Token: Missing oid")
        return ws_response(401, {"error": "Invalid Token: Missing oid"})

    body = json.loads(event["body"])

    game_session_uuid = body.get("game_session_uuid")
    question_uuid = body.get("question_uuid")
    answer_uuid = body.get("answer_uuid")
    answered_at = datetime.datetime.now().isoformat()

    if not game_session_uuid:
        return ws_response(400, {"error": "Missing game_session_uuid"})
    if not question_uuid:
        return ws_response(400, {"error": "Missing question_uuid"})
    if not answer_uuid:
        return ws_response(400, {"error": "Missing answer_uuid"})
    
    try:
        game_session = game_sessions_table.get_item(Key={"uuid": game_session_uuid}).get("Item")

        users = game_session.get("users", [])
        if not any(user["user_uuid"] == user_uuid for user in users):
            return ws_response(403, {"error": "User not in game session"})

        player_answers = get_player_answers(game_session_uuid, question_uuid)
        if not player_answers:
            return ws_response(404, {"error": "No player answers found"})
        
        # Update the answer of the player
        for player_answer in player_answers:
            if player_answer["user_uuid"] == user_uuid:
                game_answers_table.update_item(
                    Key = {
                        "game_session_uuid": game_session_uuid,
                        "uuid": player_answer["uuid"]
                    },
                    UpdateExpression = "SET answer = :answer, answered_at = :answered_at",
                    ExpressionAttributeValues = {":answer": answer_uuid, ":answered_at": answered_at}
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
            task_token = game_session.get("task_token")
            logger.info(f"Task token: {task_token}")
#            task_token = game_sessions_table.get_item(Key={"uuid": game_session_uuid}, ProjectionExpression="task_token")
#            logger.info(f"Task token: {task_token}")
            if not task_token:
                return ws_response(404, {"error": "Task token not found"})

            stepfunctions = boto3.client("stepfunctions")
            stepfunctions.send_task_success(
                taskToken=task_token,
                output=json.dumps({"message": "All players have answered"})
            )
            logger.info(f"Task success sent to step function")

        return ws_response(200, {"message": "Answer saved successfully"})



        

    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return ws_response(500, {"error": str(e)})

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

def ws_response(status_code, body):
    return {"statusCode": status_code, "body": body}

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