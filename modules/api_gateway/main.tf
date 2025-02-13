resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "iu-quiz-api-gateway-${var.stage}"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins = ["https://dev.iu-quiz.de"]
    allow_methods = ["OPTIONS", "HEAD"]
    allow_headers = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
  }
}

resource "aws_apigatewayv2_stage" "api_gateway_stage" {
  api_id = aws_apigatewayv2_api.api_gateway.id

  name        = var.stage
  auto_deploy = true
  #  default_route_settings {}
  #This displays the logs in cloudwatch
  access_log_settings {
    destination_arn = var.api_gateway_cw_log_group_arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      protocol                = "$context.protocol"
      httpMethod              = "$context.httpMethod"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      }
    )
  }
}

resource "aws_apigatewayv2_domain_name" "domain_name" {
  domain_name = "api.${var.domain}"

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  api_id      = aws_apigatewayv2_api.api_gateway.id
  domain_name = aws_apigatewayv2_domain_name.domain_name.domain_name
  stage       = var.stage
}
