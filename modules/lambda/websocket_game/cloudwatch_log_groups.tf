resource "aws_cloudwatch_log_group" "send_next_question" {
  name              = "/aws/lambda/${var.stage}/game/send-next-question"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "send_final_results" {
  name              = "/aws/lambda/${var.stage}/game/send-final-results"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "save_player_answer" {
  name              = "/aws/lambda/${var.stage}/game/save-player-answer"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "send_updated_game_session" {
  name              = "/aws/lambda/${var.stage}/websocket/send_updated_game_session"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "start_game_session" {
  name              = "/aws/lambda/${var.stage}/websocket/start_game_session"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "send_action_message" {
  name              = "/aws/lambda/${var.stage}/websocket/send_action_message"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}
