#create game session
resource "aws_apigatewayv2_integration" "gateway_integration_create_game_session" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "CREATE endpoint for game session"
  integration_method = "POST"
  integration_uri    = var.create_game_session_function_invoke_arn
  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }
}

resource "aws_apigatewayv2_route" "create_game_session_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "POST /create-game-session"
  target    = "integrations/${aws_apigatewayv2_integration.gateway_integration_create_game_session.id}"
}

#start game session
resource "aws_apigatewayv2_integration" "start_game_session" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "START endpoint for game session"
  integration_method = "POST"
  integration_uri    = var.start_game_session_function_invoke_arn
  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }
}

resource "aws_apigatewayv2_route" "start_game_session_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "POST /start-game-session"
  target    = "integrations/${aws_apigatewayv2_integration.start_game_session.id}"
}

# get game session
resource "aws_apigatewayv2_integration" "gateway_integration_get_game_session" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "GET endpoint for game session"
  integration_method = "POST"
  integration_uri    = var.get_game_session_function_invoke_arn
  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }
}

resource "aws_apigatewayv2_route" "get_game_session_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "GET /game-session/{uuid}"
  target    = "integrations/${aws_apigatewayv2_integration.gateway_integration_get_game_session.id}"
}

# get game sessions
resource "aws_apigatewayv2_integration" "gateway_integration_get_game_sessions" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "GET endpoint for game sessions"
  integration_method = "POST"
  integration_uri    = var.get_game_sessions_function_invoke_arn
  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }
}

resource "aws_apigatewayv2_route" "get_game_sessions_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "GET /game-sessions"
  target    = "integrations/${aws_apigatewayv2_integration.gateway_integration_get_game_sessions.id}"
}