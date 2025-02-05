resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "iu-quiz-api-gateway-${var.stage}"
  protocol_type = "HTTP"
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

resource "aws_apigatewayv2_integration" "gateway_integration_question_get" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "GET endpoint for questions"
  integration_method = "POST"
  integration_uri    = var.get_question_function_invoke_arn
  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }
}

resource "aws_apigatewayv2_route" "get_question_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "GET /question"
  target    = "integrations/${aws_apigatewayv2_integration.gateway_integration_question_get.id}"
}

resource "aws_apigatewayv2_integration" "gateway_integration_question_post" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "POST endpoint for questions"
  integration_method = "POST"
  integration_uri    = var.post_question_function_invoke_arn
  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }
}

resource "aws_apigatewayv2_route" "post_question_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "POST /question"
  target    = "integrations/${aws_apigatewayv2_integration.gateway_integration_question_post.id}"
}
