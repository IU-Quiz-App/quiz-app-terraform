resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gw/${var.stage}"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "lambda_questions" {
  name              = "/aws/lambda/${var.stage}/questions"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}
