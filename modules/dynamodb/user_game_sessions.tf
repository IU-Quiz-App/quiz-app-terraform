resource "aws_dynamodb_table" "users_game_sessions" {
  name         = "iu-quiz-users-game-sessions-${var.stage}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_uuid"
  range_key    = "game_session_uuid"

  attribute {
    name = "user_uuid"
    type = "S"
  }

  attribute {
    name = "game_session_uuid"
    type = "S"
  }

  global_secondary_index {
    name            = "GameSessionUsersIndex"
    hash_key        = "game_session_uuid"
    range_key       = "user_uuid"
    projection_type = "ALL"
  }
}