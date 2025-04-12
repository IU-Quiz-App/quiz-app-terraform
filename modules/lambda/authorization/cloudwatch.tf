resource "aws_cloudwatch_log_group" "get_ephemeral_token" {
  name              = "/aws/lambda/${var.stage}/authorization/get_ephemeral_token"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}
