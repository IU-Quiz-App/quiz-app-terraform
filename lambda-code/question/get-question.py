import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
domain = os.environ.get('DOMAIN')
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(f"iu-quiz-questions-{stage}")

def lambda_handler(event, context):
    cors_headers = {
        "Access-Control-Allow-Origin": "https://" + domain,
        "Access-Control-Allow-Methods": "GET, OPTIONS, HEAD",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Credentials": "true"
    }
    
    try:
        logger.info("Event: %s", event)
        
        uuid = event["pathParameters"].get("uuid")

        logger.info("Getting question with uuid: %s", uuid)

        response = table.query(
            IndexName="uuid_index",
            KeyConditionExpression="#uuid = :question_uuid",
            ExpressionAttributeNames={
                "#uuid": "uuid"
            },
            ExpressionAttributeValues={
                ":question_uuid": uuid
            }
        )
        
        logger.info("Got question: %s", response)

        if 'Items' not in response or not response['Items']:
            raise ValueError(f"No question found for UUID: {uuid}")
        
        item = response.get("Items")[0]

        logger.info("Got items: %s", item)

        return {
            "statusCode": 200,
            "headers": cors_headers,
            "body": json.dumps(item)
        }

    except Exception as e:
        logger.error("Error getting the question: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": cors_headers,
            "body": json.dumps({"error": str(e)})
        }