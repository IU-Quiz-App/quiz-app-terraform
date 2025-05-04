data "archive_file" "lambda_put_question_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/question/put-question.py"
  output_path = "${path.module}/put-question.zip"
}

resource "aws_lambda_function" "put_question" {
  function_name    = "put_question_${var.stage}"
  description      = "Update a question"
  handler          = "put-question.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_put_question_zip.output_path
  source_code_hash = data.archive_file.lambda_put_question_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.put_question.name
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

resource "aws_lambda_permission" "api_gw_trigger_put_question_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.put_question.function_name
  principal     = "apigateway.amazonaws.com"

  #TODO: try -> source_arn = "${var.api_gateway_execution_arn}/question/PUT"
  source_arn = "${var.api_gateway_execution_arn}/*/*"
}