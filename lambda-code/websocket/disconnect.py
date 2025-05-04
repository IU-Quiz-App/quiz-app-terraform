import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
REGION = 'eu-central-1'
DYNAMODB_CLIENT = boto3.client('dynamodb', region_name=REGION)

CONNECTION_TABLE_NAME = f"websocket-connections-{stage}"

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):

    logger.info(f"Received message: {event}")
    connection_id = event['requestContext']['connectionId']

    try:
        DYNAMODB_CLIENT.delete_item(
            TableName=CONNECTION_TABLE_NAME,
            Key={'connection_uuid': {'S': connection_id}}
        )
        logger.info("Successfully deleted connection from connections table")
        return {'statusCode': 200, 'body': 'Disconnected'}

    except Exception as e:
        logger.error("Error saving the answer: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }