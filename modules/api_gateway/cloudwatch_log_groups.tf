resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "/aws/api_gateway/${var.stage}/api_gateway"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "websocket_api_gw" {
  name              = "/aws/api_gateway/${var.stage}/websocket_api_gateway"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}
