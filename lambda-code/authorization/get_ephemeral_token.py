import json
import time
import secrets
import boto3
import os
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
#REGION = 'eu-central-1'
#dynamodb = boto3.client('dynamodb', region_name=REGION)
dynamodb = boto3.resource('dynamodb')
token_table = dynamodb.Table(f"ephemeral-tokens-{stage}")

CORS_HEADERS = {
    "Access-Control-Allow-Origin": f"https://{domain}",
    "Access-Control-Allow-Methods": "GET, OPTIONS, HEAD",
    "Access-Control-Allow-Headers": "*",
    "Access-Control-Allow-Credentials": "true"
}

def lambda_handler(event, context):
    logger.info(f"Received event: {json.dumps(event)}")

    token = secrets.token_urlsafe(16)  # 128-bit token
    expiration = int(time.time()) + 60  # 1-minute expiry

    access_token = event["headers"].get("authorization", "")

    if not access_token:
        return response(401, {"error": "Invalid access token."})

    item = {
        'token': token,
        'expires_at': expiration,
        'used': False,
        'access_token': access_token,
    }
    logger.info(f"Generated item to store: {item}")

    try:
        token_table.put_item(Item=item)
        logger.info(f"Stored token: {token} with expiration: {expiration}")
        return response(200, {"message": "Ephemeral token created successfully", "token": token})
    except Exception as e:
        logger.error(f"Error storing token in DynamoDB: {e}")
        return response(500, {"error": "Error creating the new ephemeral token"})

def response(status_code, body):
    return {"statusCode": status_code, "headers": CORS_HEADERS, "body": json.dumps(body)}