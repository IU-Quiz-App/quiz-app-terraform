import json
import time
import secrets
import boto3

dynamodb = boto3.client('dynamodb')
token_table = dynamodb.Table(f"ephemeral-tokens-{stage}")


def lambda_handler(event, context):
    token = secrets.token_urlsafe(16)  # 128-bit token
    expiration = int(time.time()) + 60  # 1-minute expiry

    item = {
        'token': token,
        'expiresAt': str(expiration),
        'used': str(False)
    }

    dynamodb.put_item(item)

    return {
        'statusCode': 200,
        'body': json.dumps({'ephemeral_token': token})
    }
