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

output "start_game_session_function_arn" {
  value       = aws_lambda_function.start_game_session.arn
  description = "ARN of the lambda function for PUT game session"
}

output "answer_question_function_invoke_arn" {
  value       = aws_lambda_function.answer_question.invoke_arn
  description = "Invoke ARN of the lambda function for POST answer question"
}

output "answer_question_function_arn" {
  value       = aws_lambda_function.answer_question.arn
  description = "ARN of the lambda function for POST answer question"
}

output "get_next_game_question_function_invoke_arn" {
  value       = aws_lambda_function.get_next_game_question.invoke_arn
  description = "Invoke ARN of the lambda function for GET next game question"
}

output "set_unanswered_questions_false_function_arn" {
  value       = aws_lambda_function.set_unanswered_questions_false.arn
  description = "ARN of the lambda function to set unanswered questions to false"
}

output "save_task_token_function_arn" {
  value       = aws_lambda_function.save_task_token.arn
  description = "ARN of the lambda function to save the task token of Wait for player answers state to DynamoDB"
}
