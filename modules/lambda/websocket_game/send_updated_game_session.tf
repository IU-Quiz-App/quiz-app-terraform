data "archive_file" "lambda_send_updated_game_session_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/websocket_game/send-updated-game-session.py"
  output_path = "${path.module}/send_updated_game_session.zip"
}

resource "aws_lambda_function" "send_updated_game_session" {
  function_name    = "send_updated_game_session_${var.stage}"
  description      = "Send the updated game session to the players"
  handler          = "send-updated-game-session.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_send_updated_game_session_zip.output_path
  source_code_hash = data.archive_file.lambda_send_updated_game_session_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.send_updated_game_session.name
  }

  environment {
    variables = {
      STAGE  = var.stage,
      DOMAIN = var.domain,
      WEBSOCKET_API_GATEWAY_ENDPOINT = var.websocket_api_gateway_endpoint
    }
  }
  #TODO:
  #dead_letter_config {}
}