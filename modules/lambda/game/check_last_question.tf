data "archive_file" "lambda_check_last_question_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/game/check-last-question.py"
  output_path = "${path.module}/check_last_question.zip"
}

resource "aws_lambda_function" "check_last_question" {
  function_name    = "check_last_question_${var.stage}"
  description      = "Check if the last question of the game is reached"
  handler          = "check-last-question.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_check_last_question_zip.output_path
  source_code_hash = data.archive_file.lambda_check_last_question_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.check_last_question.name
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
