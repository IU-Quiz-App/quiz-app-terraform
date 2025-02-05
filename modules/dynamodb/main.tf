resource "aws_dynamodb_table" "questions" {
  name         = "iu-quiz-questions"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "question_id"
    type = "S"
  }

  attribute {
    name = "group"
    type = "S"
  }

  attribute {
    name = "creator_user_id"
    type = "S"
  }

  # public, private
  attribute {
    name = "visibility"
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

  hash_key  = "group"
  range_key = "question_id"

  # GSI for getting all questions of a user
  global_secondary_index {
    name            = "user_questions_index"
    hash_key        = "creator_user_id"
    range_key       = "created_at"
    projection_type = "ALL"
  }

  # GSI for group and status
  global_secondary_index {
    name            = "group_status_index"
    hash_key        = "group"
    range_key       = "status"
    projection_type = "ALL"
  }

  # GSI for getting public questions of a group
  global_secondary_index {
    name            = "question_visibility_index"
    hash_key        = "group"
    range_key       = "visibility"
    projection_type = "ALL"
  }
}

# JSON model
#{
#  "question_id": "q123",
#  "group": "history",
#  "question_text": "Wer war der erste Bundeskanzler Deutschlands?",
#  "wrong_answer_1": "Angela Merkel",
#  "wrong_answer_2": "Helmut Kohl",
#  "wrong_answer_3": "Gerhard Schröder",
#  "correct_answer": "Konrad Adenauer",
#  "creator_user_id": "user_789",
#  "status": "public",
#  "created_at": "2024-02-02T12:00:00Z"
#}

# Eine Frage einer Gruppe abrufen
# SELECT * FROM quiz_questions WHERE group = 'history' LIMIT 1;

# Alle Fragen eines Erstellers abrufen (Nutzt das user_questions_index GSI)
# SELECT * FROM quiz_questions WHERE creator_user_id = 'user_789' ORDER BY created_at DESC;

# Alle Fragen einer Gruppe mit bestimmtem Status abrufen (Nutzt das group_status_index GSI)
# SELECT * FROM quiz_questions WHERE group = 'history' AND status = 'public';

# Konkret eine Frage mit Antworten abrufen
# SELECT * FROM quiz_questions WHERE group = 'history' AND question_id = 'q123';

#aws dynamodb query \
#  --table-name quiz_questions \
#  --index-name user_questions_index \
#  --key-condition-expression "creator_user_id = :creator_id" \
#  --expression-attribute-values  '{":creator_id": {"S": "user_789"}}'
