data "archive_file" "lambda_set_unanswered_questions_false_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/game/set-unanswered-questions-false.py"
  output_path = "${path.module}/set_unanswered_questions_false.zip"
}

resource "aws_lambda_function" "set_unanswered_questions_false" {
  function_name    = "set_unanswered_questions_false_${var.stage}"
  description      = "Set all unanswered questions to false"
  handler          = "set-unanswered-questions-false.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_set_unanswered_questions_false_zip.output_path
  source_code_hash = data.archive_file.lambda_set_unanswered_questions_false_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.set_unanswered_questions_false.name
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
