resource "aws_cloudwatch_log_group" "websocket_connect" {
  name              = "/aws/lambda/${var.stage}/websocket/connect"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "websocket_disconnect" {
  name              = "/aws/lambda/${var.stage}/websocket/disconnect"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "update_websocket_information" {
  name              = "/aws/lambda/${var.stage}/websocket/update_websocket_information"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}
