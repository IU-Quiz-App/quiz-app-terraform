import json
import boto3
import logging
import datetime
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
    created_at = datetime.datetime.now().isoformat()

    try:
        connection_endpoint = 'wss://' + event['requestContext']['domainName'] + '/' + event['requestContext']['stage']
        DYNAMODB_CLIENT.put_item(
            TableName=CONNECTION_TABLE_NAME,
            Item={
                'connection_uuid': {'S': connection_id},
                'connectionEndpoint': {'S': connection_endpoint},
                'start_time': {'S': created_at}
            })
        logger.info("Successfully added connection to connections table")
        return {
            "statusCode": 200,
            "headers": CORS_HEADERS,
            "body": "Successfully Connected"
        }
    
    except Exception as e:
        logger.error("Error saving the answer: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": str(e)})
        }