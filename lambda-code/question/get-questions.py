import json
import boto3
import logging
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger()

stage = os.environ.get('STAGE')
dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(f"iu-quiz-questions-{stage}")

def lambda_handler(event, context):
    cors_headers = {
        "Access-Control-Allow-Origin": "https://dev.iu-quiz.de",
        "Access-Control-Allow-Methods": "GET, OPTIONS, HEAD",
        "Access-Control-Allow-Headers": "*",
        "Access-Control-Allow-Credentials": "true"
    }

    try:
        logger.info("Event: %s", event)

        user_id = event["queryStringParameters"].get("user_id")

        response = table.query(
                IndexName="user_questions_index",
                KeyConditionExpression="#created_by = :user_id",
                ExpressionAttributeNames={
                    "#created_by": "created_by"
                },
                ExpressionAttributeValues={
                    ":user_id": user_id
                }
            )
        
        
        logger.info("Got questions: %s", response)

        items = response.get("Items")

        logger.info("Got items: %s", items)

        return {
            "statusCode": 200,
            "headers": cors_headers,
            "body": json.dumps(items)
        }
    
    except Exception as e:
        logger.error("Error getting the questions: %s", str(e), exc_info=True)
        return {
            "statusCode": 500,
            "headers": cors_headers,
            "body": json.dumps({"error": str(e)})
        }