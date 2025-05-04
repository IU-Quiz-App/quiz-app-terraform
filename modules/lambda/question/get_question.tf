data "archive_file" "lambda_get_question_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/question/get-question.py"
  output_path = "${path.module}/get-question.zip"
}

resource "aws_lambda_function" "get_question" {
  function_name    = "get_question_${var.stage}"
  description      = "Get a question"
  handler          = "get-question.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_get_question_zip.output_path
  source_code_hash = data.archive_file.lambda_get_question_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.get_question.name
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

resource "aws_lambda_permission" "api_gw_trigger_get_question_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_question.function_name
  principal     = "apigateway.amazonaws.com"

  #TODO: try -> source_arn = "${var.api_gateway_execution_arn}/question/GET"
  source_arn = "${var.api_gateway_execution_arn}/*/*"
}