# Structure of Lambda resources

Lambda Function:
- Serverless compute resource that executes the application code
- Each function has its own configuration, code and runtime environment

Lambda Execution Role:
- IAM role to grant Lambda functions access to AWS services and resources

Deployment Package:
- Lambda function code and dependencies packaged as ZIP file stored in S3
- Lambda retrieves the package and runs code when triggered

Environment Variables:
- Used for config settings, secrets and other parameters
- Can be accessed within the code

Triggers:
- Defines which service can execute the Lambda function
- In most cases in this project API Gateway is configured as trigger