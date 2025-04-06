resource "aws_cloudwatch_log_group" "get_game_session" {
  name              = "/aws/lambda/${var.stage}/game/get-game-session"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "get_game_sessions" {
  name              = "/aws/lambda/${var.stage}/game/get-game-sessions"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "create_game_session" {
  name              = "/aws/lambda/${var.stage}/game/create-game-session"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "answer_question" {
  name              = "/aws/lambda/${var.stage}/game/answer-question"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "get_next_game_question" {
  name              = "/aws/lambda/${var.stage}/game/get-next-game-question"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "set_unanswered_questions_false" {
  name              = "/aws/lambda/${var.stage}/game/set-unanswered-questions-false"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "save_task_token" {
  name              = "/aws/lambda/${var.stage}/game/save-task-token"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "join_game_session" {
  name              = "/aws/lambda/${var.stage}/game/join_game_session"
  log_group_class   = "STANDARD"
  retention_in_days = 30

}
