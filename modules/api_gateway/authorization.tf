#get ephemeral token
resource "aws_apigatewayv2_integration" "gateway_integration_get_ephemeral_token" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "GET endpoint for ephemeral token"
  integration_method = "POST"
  integration_uri    = var.get_ephemeral_token_function_invoke_arn
  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }
}

resource "aws_apigatewayv2_route" "get_ephemeral_token_route" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  route_key          = "GET /authorization/token"
  target             = "integrations/${aws_apigatewayv2_integration.gateway_integration_get_ephemeral_token.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.api_gateway_authorizer.id
}
