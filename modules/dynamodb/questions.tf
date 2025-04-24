resource "aws_dynamodb_table" "questions" {
  name                        = "iu-quiz-questions-${var.stage}"
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
    name = "course"
    type = "S"
  }

  attribute {
    name = "created_by"
    type = "S"
  }

  # public, private
  attribute {
    name = "public"
    type = "S"
  }

  # waiting for approval, approved, commented
  attribute {
    name = "status"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  hash_key  = "course"
  range_key = "uuid"

  # GSI for getting all questions of a user
  global_secondary_index {
    name            = "user_questions_index"
    hash_key        = "created_by"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  # GSI for course and status
  global_secondary_index {
    name            = "course_status_index"
    hash_key        = "course"
    range_key       = "status"
    projection_type = "ALL"
  }

  # GSI for getting public questions of a course
  global_secondary_index {
    name            = "question_visibility_index"
    hash_key        = "course"
    range_key       = "public"
    projection_type = "ALL"
  }

  # GSI for getting a question by its uuid
  global_secondary_index {
    name            = "uuid_index"
    hash_key        = "uuid"
    projection_type = "ALL"
  }

  # GSI for getting all questions of a user based on a course
  global_secondary_index {
    name            = "user_course_index"
    hash_key        = "created_by"
    range_key       = "course"
    projection_type = "ALL"
  }
}
