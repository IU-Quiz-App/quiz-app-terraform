resource "aws_dynamodb_table" "websocket_connections" {
  name         = "ephemeral-tokens-${var.stage}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "token"

  attribute {
    name = "token"
    type = "S"
  }
}
