output "send_next_question_function_arn" {
  value       = aws_lambda_function.send_next_question.arn
  description = "Invoke ARN of the lambda function to send the next question to players"
}

output "send_final_results_function_arn" {
  value       = aws_lambda_function.send_final_results.arn
  description = "ARN of the lambda function to send the final results to players"
}
