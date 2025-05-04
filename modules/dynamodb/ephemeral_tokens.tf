resource "aws_dynamodb_table" "ephemeral_tokens" {
  name         = "ephemeral-tokens-${var.stage}"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "token"

  attribute {
    name = "token"
    type = "S"
  }

  ttl {
    attribute_name = "expires_at"
    enabled        = true
  }
}
