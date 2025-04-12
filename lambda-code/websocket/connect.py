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
TOKEN_TABLE_NAME = f"ephemeral-tokens-{stage}"

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "POST, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):

    logger.info(f"Received message: {event}")
    connection_id = event['requestContext']['connectionId']

    logger.info("Check if ephemeral token is valid")
    token = event['queryStringParameters'].get('access_token', None)
    if token is None:
        logger.error("Token is missing")
        return response(401, {"error": "Unauthorized because token was not found"})
    logger.info(f"Token: {token}")

    try:
        ephemeral_token = DYNAMODB_CLIENT.get_item(
            TableName=TOKEN_TABLE_NAME,
            Key={
                'token': {'S': token},
            }
        )
        if 'Item' not in ephemeral_token:
            logger.error(f"Token {ephemeral_token} not found")
            return response(401, {"error": "Unauthorized because token was not found"})
        if ephemeral_token['Item']['used']['BOOL'] == True:
            logger.error(f"Token {ephemeral_token} already used")
            return response(401, {"error": "Unauthorized because token was already used"})
        if int(ephemeral_token['Item']['expiresAt']['N']) < int(datetime.datetime.now().timestamp()):
            logger.error(f"Token {ephemeral_token} expired")
            return response(401, {"error": "Unauthorized because token was expired"})
        logger.info("Token is valid, updating token to used")

        DYNAMODB_CLIENT.update_item(
            TableName=TOKEN_TABLE_NAME,
            Key={
                'token': {'S': token},
            },
            UpdateExpression="SET used = :used",
            ExpressionAttributeValues={
                ':used': {'BOOL': True}
            }
        )
        logger.info("Token updated to used")
    except Exception as e:
        logger.error("Error checking token: %s", str(e), exc_info=True)
        return response(500, {"error": str(e)})
    
    try:
        logger.info("Adding connection to connections table")

        created_at = datetime.datetime.now().isoformat()
        connection_endpoint = 'wss://' + event['requestContext']['domainName'] + '/' + event['requestContext']['stage']

        DYNAMODB_CLIENT.put_item(
            TableName=CONNECTION_TABLE_NAME,
            Item={
                'connection_uuid': {'S': connection_id},
                'connectionEndpoint': {'S': connection_endpoint},
                'start_time': {'S': created_at}
            })
        logger.info("Successfully added connection to connections table")
        return response(200, {"message": "Connected successfully"})
    
    except Exception as e:
        logger.error("Error saving the answer: %s", str(e), exc_info=True)
        return response(500, {"error": str(e)})
    
def response(status_code, body):
    return {"statusCode": status_code, "headers": CORS_HEADERS, "body": json.dumps(body)}