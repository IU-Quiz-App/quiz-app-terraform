resource "aws_dynamodb_table" "user_game_sessions" {
  name                        = "iu-quiz-user-game-sessions-${var.stage}"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = true
  point_in_time_recovery {
    enabled = true
  }

  hash_key  = "game_session_uuid"
  range_key = "user_uuid"

  attribute {
    name = "user_uuid"
    type = "S"
  }

  attribute {
    name = "game_session_uuid"
    type = "S"
  }
}
