import json
import os
import logging
import datetime
import boto3

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
websocket_wss_api_endpoint = os.environ.get('WEBSOCKET_API_GATEWAY_ENDPOINT')
websocket_api_endpoint = f"{websocket_wss_api_endpoint.replace('wss', 'https')}/{stage}"

dynamodb = boto3.resource("dynamodb")
game_session_table = dynamodb.Table(f"iu-quiz-game-sessions-{stage}")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")
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