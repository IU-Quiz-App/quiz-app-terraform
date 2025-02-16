resource "aws_dynamodb_table" "game_sessions" {
  name         = "iu-quiz-game-sessions-${var.stage}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "uuid"

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

  attribute {
    name = "started_at"
    type = "S"
  }

  attribute {
    name = "ended_at"
    type = "S"
  }

  global_secondary_index {
    name            = "ActiveSessionsIndex"
    hash_key        = "ended_at"
    range_key       = "started_at"
    projection_type = "ALL"
  }

  global_secondary_index {
      name            = "UserSessionsIndex"
      hash_key        = "created_by"
      range_key       = "created_at"
      projection_type = "ALL"
  }
}