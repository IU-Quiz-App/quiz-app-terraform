# Structure of API Gateways

API Gateway: 
- Core resource that acts as front door to the APIs
- Provides HTTP endpoints for clients

API Gateway Stage:
- Versions/environments of the API
- In this project not used for different environments, every stage has it's own API Gateway

API Gateway Route:
- Defines which request is routed to which target
- Resources: Paths in the API (e.g /question)
- Route key: HTTP methods (GET, POST, PUT, DELETE) associated with the resources

API Gateway Integration:
- Connects the API Gateway to a Lambda function or other AWS services

API Gateway Authorizer:
- Control access to the API by validating user credentials or tokens

API Gateway Custom Domain:
- Used instead of the default API Gateway URL (in this case api.iu-quiz.de)