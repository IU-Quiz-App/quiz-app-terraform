resource "aws_dynamodb_table" "user_questions" {
  name           = "iu-quiz-user-questions-${var.stage}"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "game_session_uuid"
  range_key      = "uuid"

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
    name = "requested_at"
    type = "S"
  }

  attribute {
    name = "answered_at"
    type = "S"
  }

  attribute {
    name = "given_answer"
    type = "S"
  }

  global_secondary_index {
    name            = "UserSessionQuestionsIndex"
    hash_key        = "game_session_uuid"
    range_key       = "user_uuid"
    projection_type = "ALL"
  }
}