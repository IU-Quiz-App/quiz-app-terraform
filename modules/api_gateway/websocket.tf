#connect
resource "aws_apigatewayv2_integration" "websocket_gateway_integration_connect" {
  api_id             = aws_apigatewayv2_api.websocket_api_gateway.id
  integration_type   = "AWS_PROXY"
  description        = "connect endpoint for websocket connection"
  integration_method = "POST"
  integration_uri    = var.websocket_connect_function_invoke_arn
  #  response_parameters {
  #    status_code = 403
  #    mappings = {
  #      "append:header.auth" = "$context.authorizer.authorizerResponse"
  #    }
  #  }
}

resource "aws_apigatewayv2_route" "connect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api_gateway.id
  route_key = "$connect"
  target    = "integrations/${aws_apigatewayv2_integration.websocket_gateway_integration_connect.id}"
}

#disconnect
resource "aws_apigatewayv2_integration" "websocket_gateway_integration_disconnect" {
  api_id             = aws_apigatewayv2_api.websocket_api_gateway.id
  integration_type   = "AWS_PROXY"
  description        = "disconnect endpoint for websocket connection"
  integration_method = "POST"
  integration_uri    = var.websocket_disconnect_function_invoke_arn
  #  response_parameters {
  #    status_code = 403
  #    mappings = {
  #      "append:header.auth" = "$context.authorizer.authorizerResponse"
  #    }
  #  } 
}

resource "aws_apigatewayv2_route" "disconnect_route" {
  api_id    = aws_apigatewayv2_api.websocket_api_gateway.id
  route_key = "$disconnect"
  target    = "integrations/${aws_apigatewayv2_integration.websocket_gateway_integration_disconnect.id}"
}

#update websocket information
resource "aws_apigatewayv2_integration" "websocket_gateway_integration_update_websocket_information" {
  api_id             = aws_apigatewayv2_api.websocket_api_gateway.id
  integration_type   = "AWS_PROXY"
  description        = "update websocket information"
  integration_method = "POST"
  integration_uri    = var.update_websocket_information_function_invoke_arn
  #  response_parameters {
  #    status_code = 403
  #    mappings = {
  #      "append:header.auth" = "$context.authorizer.authorizerResponse"
  #    }
  #  } 
}

resource "aws_apigatewayv2_route" "update_websocket_information_route" {
  api_id    = aws_apigatewayv2_api.websocket_api_gateway.id
  route_key = "update-websocket-information"
  target    = "integrations/${aws_apigatewayv2_integration.websocket_gateway_integration_update_websocket_information.id}"
}

#save player answer
resource "aws_apigatewayv2_integration" "websocket_gateway_integration_save_player_answer" {
  api_id             = aws_apigatewayv2_api.websocket_api_gateway.id
  integration_type   = "AWS_PROXY"
  description        = "save player answer"
  integration_method = "POST"
  integration_uri    = var.save_player_answer_function_invoke_arn
  #  response_parameters {
  #    status_code = 403
  #    mappings = {
  #      "append:header.auth" = "$context.authorizer.authorizerResponse"
  #    }
  #  } 
}

resource "aws_apigatewayv2_route" "save_player_answer_route" {
  api_id    = aws_apigatewayv2_api.websocket_api_gateway.id
  route_key = "save-player-answer"
  target    = "integrations/${aws_apigatewayv2_integration.websocket_gateway_integration_save_player_answer.id}"
}
