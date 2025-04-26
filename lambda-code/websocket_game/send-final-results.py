import json
import os
import logging
import datetime
import boto3
from decimal import Decimal

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
websocket_wss_api_endpoint = os.environ.get('WEBSOCKET_API_GATEWAY_ENDPOINT')
websocket_api_endpoint = f"{websocket_wss_api_endpoint.replace('wss', 'https')}/{stage}"

dynamodb = boto3.resource("dynamodb")
game_session_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")
user_game_sessions_table = dynamodb.Table(f"iu-quiz-user-game-sessions-{stage}")
lambda_client = boto3.client("lambda")

apigateway_management = boto3.client(
    "apigatewaymanagementapi",
    endpoint_url=websocket_api_endpoint
)

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    game_session_uuid = event.get("game_session_uuid")

    if not game_session_uuid:
        logger.error("Missing game_session_uuid")
        raise ValueError("Missing game_session_uuid")
    try:

        ended_at = datetime.datetime.now().isoformat()

        game_session_table.update_item(
            Key={"uuid": game_session_uuid},
            UpdateExpression="SET ended_at = :ended_at",
            ExpressionAttributeValues={
                ":ended_at": ended_at
            }
        )

        update_user_game_sessions(game_session_uuid, ended_at)

        update_game_session_response = lambda_client.invoke(
            FunctionName=f"send_updated_game_session_{stage}",
            InvocationType="Event",
            Payload=json.dumps({
                "game_session_uuid": game_session_uuid,
                "update_reason": "final-results"
            })
        )

        logger.info(f"Update game session lambda invoked: {update_game_session_response}")

        return response(200, {"message": "Final results sent to all players"})
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return response(500, {"error": str(e)})

def response(status_code, body):
    return {"statusCode": status_code, "body": body}

def update_user_game_sessions(game_session_uuid, ended_at):
    try:
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

        for item in items:
            user_uuid = item["user_uuid"]
            user_game_sessions_table.update_item(
                Key={"user_uuid": user_uuid, "game_session_uuid": game_session_uuid},
                UpdateExpression="SET ended_at = :ended_at",
                ExpressionAttributeValues={":ended_at": ended_at}
            )
            logger.info(f"Updated item: {game_session_uuid} for user: {user_uuid} with ended_at: {ended_at}")

    except Exception as e:
        logger.error(f"Error updating user game sessions: {str(e)}", exc_info=True)

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