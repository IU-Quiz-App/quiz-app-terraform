resource "aws_cloudwatch_log_group" "get_question" {
  name              = "/aws/lambda/${var.stage}/question/get-question"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "post_question" {
  name              = "/aws/lambda/${var.stage}/question/post-question"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "delete_question" {
  name              = "/aws/lambda/${var.stage}/question/delete-question"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}
