data "archive_file" "lambda_save_task_token_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/game/save-task-token.py"
  output_path = "${path.module}/save-task-token.zip"
}

resource "aws_lambda_function" "save_task_token" {
  function_name    = "save_task_token${var.stage}"
  description      = "Save the task token to the Wait for player answers state to DynamoDB"
  handler          = "save-task-token.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_save_task_token_zip.output_path
  source_code_hash = data.archive_file.lambda_save_task_token_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.save_task_token.name
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

resource "aws_lambda_permission" "api_gw_trigger_save_task_token_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.save_task_token.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.api_gateway_execution_arn}/*/*"
}
