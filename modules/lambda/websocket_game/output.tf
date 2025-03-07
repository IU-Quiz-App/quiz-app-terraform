output "send_next_question_function_invoke_arn" {
  value       = aws_lambda_function.send_next_question.arn
  description = "Invoke ARN of the lambda function to send the next question to players"
}
