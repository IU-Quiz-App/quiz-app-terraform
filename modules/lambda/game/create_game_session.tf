data "archive_file" "lambda_create_game_session_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/game/create-game-session.py"
  output_path = "${path.module}/create-game-session.zip"
}

resource "aws_lambda_function" "create_game_session" {
  function_name    = "create_game_session_${var.stage}"
  description      = "Create a game session"
  handler          = "create-game-session.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_create_game_session_zip.output_path
  source_code_hash = data.archive_file.lambda_create_game_session_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.create_game_session.name
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

resource "aws_lambda_permission" "api_gw_trigger_create_game_session_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.create_game_session.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_execution_arn}/*/*"
}