output "send_next_question_function_arn" {
  value       = aws_lambda_function.send_next_question.arn
  description = "Invoke ARN of the lambda function to send the next question to players"
}

output "send_final_results_function_arn" {
  value       = aws_lambda_function.send_final_results.arn
  description = "ARN of the lambda function to send the final results to players"
}

output "save_player_answer_function_invoke_arn" {
  value       = aws_lambda_function.save_player_answer.invoke_arn
  description = "Invoke ARN of the lambda function for saving the answer of a player"
}

output "send_updated_game_session_function_arn" {
  value       = aws_lambda_function.send_updated_game_session.invoke_arn
  description = "ARN of the lambda function to send the updated game session to players"
}

output "start_game_session_function_arn" {
  value       = aws_lambda_function.start_game_session.invoke_arn
  description = "ARN of the lambda function for start the game session"
}

output "send_action_message_function_arn" {
  value       = aws_lambda_function.send_action_message.arn
  description = "ARN of the lambda function to send the action message to players"
}
