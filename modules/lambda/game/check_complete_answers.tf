data "archive_file" "lambda_check_complete_answers_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/game/check-complete-answers.py"
  output_path = "${path.module}/check_complete_answers.zip"
}

resource "aws_lambda_function" "check_complete_answers" {
  function_name    = "check_complete_answers_${var.stage}"
  description      = "Check if all players have answered a question"
  handler          = "check-complete-answers.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_check_complete_answers_zip.output_path
  source_code_hash = data.archive_file.lambda_check_complete_answers_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.check_complete_answers.name
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
