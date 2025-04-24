resource "aws_dynamodb_table" "game_answers" {
  name                        = "iu-quiz-game-answers-${var.stage}"
  billing_mode                = "PAY_PER_REQUEST"
  deletion_protection_enabled = true
  point_in_time_recovery {
    enabled = true
  }

  attribute {
    name = "uuid"
    type = "S"
  }

  attribute {
    name = "game_session_uuid"
    type = "S"
  }

  attribute {
    name = "user_uuid"
    type = "S"
  }

  attribute {
    name = "question_uuid"
    type = "S"
  }

  attribute {
    name = "user_question"
    type = "S"
  }

  hash_key  = "game_session_uuid"
  range_key = "uuid"

  # GSI for getting all answers of a user
  global_secondary_index {
    name            = "user_answers_index"
    hash_key        = "game_session_uuid"
    range_key       = "user_uuid"
    projection_type = "ALL"
  }

  # GSI for getting all the uuid of a game session - user - question combination
  global_secondary_index {
    name            = "game_session_user_question_index"
    hash_key        = "game_session_uuid"
    range_key       = "user_question"
    projection_type = "ALL"
  }

  # GSI for getting all answers of a specific question from a game session
  global_secondary_index {
    name            = "game_session_question_index"
    hash_key        = "game_session_uuid"
    range_key       = "question_uuid"
    projection_type = "ALL"
  }
}
