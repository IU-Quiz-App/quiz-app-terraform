import time
def lambda_handler(event, context):
    time.sleep(7)
    return {
        'statusCode': 200,
        'body': 'This method is not implemented yet but don\'t be afraid, it will work soon! It will be the method to send final results to the players'
    }