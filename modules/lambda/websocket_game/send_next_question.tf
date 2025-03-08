data "archive_file" "lambda_send_next_question_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/websocket_game/send-next-question.py"
  output_path = "${path.module}/send_next_question.zip"
}

resource "aws_lambda_function" "send_next_question" {
  function_name    = "send_next_question_${var.stage}"
  description      = "Send the next question to the player"
  handler          = "send-next-question.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_send_next_question_zip.output_path
  source_code_hash = data.archive_file.lambda_send_next_question_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.send_next_question.name
  }

  environment {
    variables = {
      STAGE                          = var.stage,
      DOMAIN                         = var.domain,
      WEBSOCKET_API_GATEWAY_ENDPOINT = var.websocket_api_gateway_endpoint
    }
  }
  #TODO:
  #dead_letter_config {}
}
