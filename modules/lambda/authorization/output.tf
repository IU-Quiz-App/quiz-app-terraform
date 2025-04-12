output "get_ephemeral_token_function_invoke_arn" {
  value       = aws_lambda_function.get_ephemeral_token.invoke_arn
  description = "Invoke ARN of the lambda function for GET ephemeral token"
}
