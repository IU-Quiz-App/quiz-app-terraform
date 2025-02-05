resource "aws_cloudwatch_log_group" "get_question" {
  name              = "/aws/lambda/${var.stage}/questions/get-question"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "post_question" {
  name              = "/aws/lambda/${var.stage}/questions/post-question"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}
