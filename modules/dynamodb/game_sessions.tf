resource "aws_dynamodb_table" "game_sessions" {
  name                        = "iu-quiz-game-sessions-${var.stage}"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = true
  point_in_time_recovery {
    enabled = true
  }

  hash_key = "uuid"

  attribute {
    name = "uuid"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  attribute {
    name = "created_by"
    type = "S"
  }

  global_secondary_index {
    name            = "user_sessions_index"
    hash_key        = "created_by"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  # GSI for getting a session by its uuid
  global_secondary_index {
    name            = "uuid_index"
    hash_key        = "uuid"
    projection_type = "ALL"
  }
}
