output "get_game_session_function_invoke_arn" {
  value       = aws_lambda_function.get_game_session.invoke_arn
  description = "Invoke ARN of the lambda function for GET game session"
}

output "get_game_sessions_function_invoke_arn" {
  value       = aws_lambda_function.get_game_sessions.invoke_arn
  description = "Invoke ARN of the lambda function for GET list of game sessions"
}

output "create_game_session_function_invoke_arn" {
  value       = aws_lambda_function.create_game_session.invoke_arn
  description = "Invoke ARN of the lambda function for POST game session"
}

output "start_game_session_function_invoke_arn" {
  value       = aws_lambda_function.start_game_session.invoke_arn
  description = "Invoke ARN of the lambda function for PUT game session"
}

output "answer_question_function_invoke_arn" {
  value       = aws_lambda_function.answer_question.invoke_arn
  description = "Invoke ARN of the lambda function for POST answer question"
}

output "get_next_game_question_function_invoke_arn" {
  value       = aws_lambda_function.get_next_game_question.invoke_arn
  description = "Invoke ARN of the lambda function for GET next game question"
}
