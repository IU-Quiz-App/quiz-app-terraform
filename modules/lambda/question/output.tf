output "get_question_function_invoke_arn" {
  value       = aws_lambda_function.get_question.invoke_arn
  description = "Invoke ARN of the lambda function for GET question"
}
