data "archive_file" "lambda_join_game_session_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/game/join_game_session.py"
  output_path = "${path.module}/join_game_session.zip"
}

resource "aws_lambda_function" "join_game_session" {
  function_name    = "join_game_session_${var.stage}"
  description      = "Join a game session"
  handler          = "join_game_session.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_join_game_session_zip.output_path
  source_code_hash = data.archive_file.lambda_join_game_session_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.join_game_session.name
  }

  environment {
    variables = {
      STAGE  = var.stage,
      DOMAIN = var.domain,
    }
  }
  #TODO:
  #dead_letter_config {}
}

resource "aws_lambda_permission" "api_gw_trigger_join_game_session_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.join_game_session.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_execution_arn}/*/*"
}
