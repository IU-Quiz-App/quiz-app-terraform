data "archive_file" "lambda_update_websocket_information_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/websocket/update-websocket-information.py"
  output_path = "${path.module}/update_websocket_information.zip"
}

resource "aws_lambda_function" "update_websocket_information" {
  function_name    = "update_websocket_information_${var.stage}"
  description      = "Answer a question of the game"
  handler          = "update-websocket-information.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_update_websocket_information_zip.output_path
  source_code_hash = data.archive_file.lambda_update_websocket_information_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.update_websocket_information.name
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

resource "aws_lambda_permission" "api_gw_trigger_update_websocket_information_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.update_websocket_information.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_execution_arn}/*/*"
}
