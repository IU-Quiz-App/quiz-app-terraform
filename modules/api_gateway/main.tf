resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "iu-quiz-api-gateway-${var.stage}"
  protocol_type = "HTTP"
  cors_configuration {
    allow_origins     = ["https://${var.domain}", "https://www.${var.domain}"]
    allow_methods     = ["GET", "POST", "PUT", "DELETE", "OPTIONS", "HEAD"]
    allow_headers     = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
    allow_credentials = true
  }
}

resource "aws_apigatewayv2_stage" "api_gateway_stage" {
  api_id = aws_apigatewayv2_api.api_gateway.id

  name        = var.stage
  auto_deploy = true
  #  default_route_settings {}
  #This displays the logs in cloudwatch
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw.arn

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

resource "aws_apigatewayv2_authorizer" "api_gateway_authorizer" {
  name             = "api-gateway-authorizer-${var.stage}"
  api_id           = aws_apigatewayv2_api.api_gateway.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  jwt_configuration {
    audience = ["6118d90d-5469-4c28-9bed-668c44ef16a7"]
    issuer   = "https://login.microsoftonline.com/c630d2a3-948c-402d-93ca-0060609c152e/v2.0"
  }
}

#Websocket API
resource "aws_apigatewayv2_api" "websocket_api_gateway" {
  name                       = "iu-quiz-websocket-api-${var.stage}"
  protocol_type              = "WEBSOCKET"
  route_selection_expression = "$request.body.action"
}

resource "aws_apigatewayv2_stage" "websocket_api_stage" {
  depends_on = [aws_api_gateway_account.websocket_api_gateway_account]
  api_id     = aws_apigatewayv2_api.websocket_api_gateway.id

  name        = var.stage
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.websocket_api_gw.arn

    format = jsonencode({
      requestId               = "$context.requestId"
      sourceIp                = "$context.identity.sourceIp"
      requestTime             = "$context.requestTime"
      resourcePath            = "$context.resourcePath"
      routeKey                = "$context.routeKey"
      status                  = "$context.status"
      responseLength          = "$context.responseLength"
      integrationErrorMessage = "$context.integrationErrorMessage"
      errorMessage            = "$context.errorMessage"
      lambdaExecutionError    = "$context.lambdaExecutionError"
      requestBody             = "$context.requestBody"
      }
    )
  }

  route_settings {
    route_key                = "$connect"
    detailed_metrics_enabled = true
    logging_level            = "INFO"
    throttling_rate_limit    = 1000
    throttling_burst_limit   = 500
  }
  route_settings {
    route_key                = "$disconnect"
    detailed_metrics_enabled = true
    logging_level            = "INFO"
    throttling_rate_limit    = 1000
    throttling_burst_limit   = 500
  }
  route_settings {
    route_key                = "$default"
    detailed_metrics_enabled = true
    logging_level            = "INFO"
    throttling_rate_limit    = 1000
    throttling_burst_limit   = 500
  }
}

resource "aws_apigatewayv2_domain_name" "websocket_domain_name" {
  domain_name = "ws.${var.domain}"

  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

resource "aws_apigatewayv2_api_mapping" "websocket_api_mapping" {
  api_id      = aws_apigatewayv2_api.websocket_api_gateway.id
  domain_name = aws_apigatewayv2_domain_name.websocket_domain_name.domain_name
  stage       = var.stage
}

resource "aws_api_gateway_account" "websocket_api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_logs_role.arn
}

# Roles and Policies for logging
resource "aws_iam_role" "api_gateway_logs_role" {
  name = "api_gateway_logs_role_${var.stage}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = ["apigateway.amazonaws.com", "lambda.amazonaws.com"]
        }
      },
    ]
  })
}

resource "aws_iam_policy" "api_gateway_logs_policy" {
  name        = "api_gateway_logs_policy_${var.stage}"
  description = "Policy to allow API Gateway to write to CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "api_gateway_logs_policy_attachment" {
  name       = "api-gateway-logs-policy-attachment"
  policy_arn = aws_iam_policy.api_gateway_logs_policy.arn
  roles      = [aws_iam_role.api_gateway_logs_role.name]
}
