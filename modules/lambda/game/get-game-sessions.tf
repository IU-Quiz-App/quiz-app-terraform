data "archive_file" "lambda_get_game_sessions_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/game/get-game-sessions.py"
  output_path = "${path.module}/get-game-sessions.zip"
}

resource "aws_lambda_function" "get_game_sessions" {
  function_name    = "get_game_sessions_${var.stage}"
  description      = "Get game sessions"
  handler          = "get-game-sessions.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_get_game_sessions_zip.output_path
  source_code_hash = data.archive_file.lambda_get_game_sessions_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.get_game_sessions.name
  }

  environment {
    variables = {
      STAGE = var.stage,
      DOMAIN = var.domain,
    }
  }
  #TODO:
  #dead_letter_config {}
}

resource "aws_lambda_permission" "api_gw_trigger_get_game_sessions_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_game_sessions.function_name
  principal     = "apigateway.amazonaws.com"

  #TODO: try -> source_arn = "${var.api_gateway_execution_arn}/game/DELETE"
  source_arn = "${var.api_gateway_execution_arn}/*/*"
}