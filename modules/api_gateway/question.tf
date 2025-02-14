#get-question
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
  route_key = "GET /question/{uuid}"
  target    = "integrations/${aws_apigatewayv2_integration.gateway_integration_question_get.id}"
}

#get-list-of-questions
resource "aws_apigatewayv2_integration" "gateway_integration_questions_get" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "GET endpoint for questions"
  integration_method = "POST"
  integration_uri    = var.get_questions_function_invoke_arn
  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }
}

resource "aws_apigatewayv2_route" "get_questions_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "GET /questions"
  target    = "integrations/${aws_apigatewayv2_integration.gateway_integration_questions_get.id}"
}

#post-question
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

#delete-question
resource "aws_apigatewayv2_integration" "gateway_integration_question_delete" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "DELETE endpoint for questions"
  integration_method = "POST"
  integration_uri    = var.delete_question_function_invoke_arn
  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }
}

resource "aws_apigatewayv2_route" "delete_question_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "DELETE /question/{uuid}"
  target    = "integrations/${aws_apigatewayv2_integration.gateway_integration_question_delete.id}"
}


#put-question
resource "aws_apigatewayv2_integration" "gateway_integration_question_put" {
  api_id             = aws_apigatewayv2_api.api_gateway.id
  integration_type   = "AWS_PROXY"
  connection_type    = "INTERNET"
  description        = "PUT endpoint for questions"
  integration_method = "POST"
  integration_uri    = var.put_question_function_invoke_arn
  response_parameters {
    status_code = 403
    mappings = {
      "append:header.auth" = "$context.authorizer.authorizerResponse"
    }
  }
}

resource "aws_apigatewayv2_route" "put_question_route" {
  api_id    = aws_apigatewayv2_api.api_gateway.id
  route_key = "PUT /question/{uuid}"
  target    = "integrations/${aws_apigatewayv2_integration.gateway_integration_question_put.id}"
}