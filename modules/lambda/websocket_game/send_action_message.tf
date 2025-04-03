data "archive_file" "lambda_send_action_message_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/websocket_game/send-action-message.py"
  output_path = "${path.module}/send_action_message.zip"
}

resource "aws_lambda_function" "send_action_message" {
  function_name    = "send_action_message_${var.stage}"
  description      = "Send action message to all players"
  handler          = "send-action-message.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_send_action_message_zip.output_path
  source_code_hash = data.archive_file.lambda_send_action_message_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.send_action_message.name
  }

  environment {
    variables = {
      STAGE                          = var.stage,
      WEBSOCKET_API_GATEWAY_ENDPOINT = var.websocket_api_gateway_endpoint
    }
  }
  #TODO:
  #dead_letter_config {}
}
