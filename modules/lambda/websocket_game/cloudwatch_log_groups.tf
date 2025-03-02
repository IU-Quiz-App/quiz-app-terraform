resource "aws_cloudwatch_log_group" "send_next_question" {
  name              = "/aws/lambda/${var.stage}/game/send-next-question"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}
