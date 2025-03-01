resource "aws_dynamodb_table" "websocket_connections" {
  name         = "websocket-connections-${var.stage}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "connectionId"

  attribute {
    name = "connectionId"
    type = "S"
  }
}
