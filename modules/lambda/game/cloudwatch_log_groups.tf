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

resource "aws_cloudwatch_log_group" "start_game_session" {
  name              = "/aws/lambda/${var.stage}/game/start-game-session"
  log_group_class   = "STANDARD"
  retention_in_days = 30
}