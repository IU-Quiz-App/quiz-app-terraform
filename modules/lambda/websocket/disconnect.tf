data "archive_file" "lambda_websocket_disconnect_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/websocket/disconnect.py"
  output_path = "${path.module}/disconnect.zip"
}

resource "aws_lambda_function" "websocket_disconnect" {
  function_name    = "disconnect_${var.stage}"
  description      = "disconnect to websocket"
  handler          = "disconnect.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_websocket_disconnect_zip.output_path
  source_code_hash = data.archive_file.lambda_websocket_disconnect_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.websocket_disconnect.name
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

resource "aws_lambda_permission" "websocket_api_gw_trigger_disconnect_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.websocket_disconnect.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_execution_arn}/*/*"
}
