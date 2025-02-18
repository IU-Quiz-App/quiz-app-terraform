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