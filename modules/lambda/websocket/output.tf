output "websocket_connect_function_invoke_arn" {
  value       = aws_lambda_function.websocket_connect.invoke_arn
  description = "Invoke ARN of the lambda function for websocket connect"
}

output "websocket_disconnect_function_invoke_arn" {
  value       = aws_lambda_function.websocket_disconnect.invoke_arn
  description = "Invoke ARN of the lambda function for websocket disconnect"
}

output "update_websocket_information_function_invoke_arn" {
  value       = aws_lambda_function.update_websocket_information.invoke_arn
  description = "Invoke ARN of the lambda function for updating websocket information"
}
