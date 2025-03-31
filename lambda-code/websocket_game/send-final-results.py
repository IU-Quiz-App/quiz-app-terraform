import json
import os
import logging
import boto3

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
websocket_wss_api_endpoint = os.environ.get('WEBSOCKET_API_GATEWAY_ENDPOINT')
websocket_api_endpoint = f"{websocket_wss_api_endpoint.replace('wss', 'https')}/{stage}"

dynamodb = boto3.resource("dynamodb")
websocket_connections_table = dynamodb.Table(f"websocket-connections-{stage}")
game_answers_table = dynamodb.Table(f"iu-quiz-game-answers-{stage}")

apigateway_management = boto3.client(
    "apigatewaymanagementapi",
    endpoint_url=websocket_api_endpoint
)

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    game_session_uuid = event.get("game_session_uuid")

    if not game_session_uuid:
        return response(400, {"error": "Missing game_session_uuid"})
    try:
        results = game_answers_table.query(
            KeyConditionExpression="game_session_uuid = :game_session_uuid",
            ExpressionAttributeValues={":game_session_uuid": game_session_uuid}
        )

        if not results.get("Items"):
            return response(404, {"error": "No results found for the game session"})
        logger.info(f"Results found: {results}")


        final_results = []
        for answer in results["Items"]:
            final_results.append({
                "user_uuid": answer["user_uuid"],
                "answer": answer["answer"],
                "correct_answer": answer["correct_answer"],
                "question_uuid": answer["question_uuid"],
                "timed_out": answer["timed_out"],
            })
        logger.info(f"Final results: {final_results}")
        send_final_results_to_all_players(game_session_uuid, final_results)
        return response(200, {"message": "Final results sent to all players"})
    except Exception as e:
        logger.error(f"Error: {str(e)}")
        return response(500, {"error": str(e)})

def send_final_results_to_all_players(game_session_uuid, results):
    logger.info(f"Sending final results to all clients in session: {game_session_uuid}")
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
                    "action": "final-result",
                    "results": results
                })
            )
            logger.info(f"Sent final results to {connection_id}")

        except apigateway_management.exceptions.GoneException:
            logger.info(f"Connection {connection_id} is gone")

def response(status_code, body):
    return {"statusCode": status_code, "body": body}