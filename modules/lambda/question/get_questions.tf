data "archive_file" "lambda_get_questions_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/question/get-questions.py"
  output_path = "${path.module}/get-questions.zip"
}

resource "aws_lambda_function" "get_questions" {
  function_name    = "get_questions_${var.stage}"
  description      = "Get list of questions"
  handler          = "get-questions.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_get_questions_zip.output_path
  source_code_hash = data.archive_file.lambda_get_questions_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.get_questions.name
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

resource "aws_lambda_permission" "api_gw_trigger_get_questions_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_questions.function_name
  principal     = "apigateway.amazonaws.com"

  #TODO: try -> source_arn = "${var.api_gateway_execution_arn}/question/GET"
  source_arn = "${var.api_gateway_execution_arn}/*/*"
}
