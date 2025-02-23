output "get_question_function_invoke_arn" {
  value       = aws_lambda_function.get_question.invoke_arn
  description = "Invoke ARN of the lambda function for GET question"
}

output "get_questions_function_invoke_arn" {
  value       = aws_lambda_function.get_questions.invoke_arn
  description = "Invoke ARN of the lambda function for GET list of questions"
}

output "post_question_function_invoke_arn" {
  value       = aws_lambda_function.post_question.invoke_arn
  description = "Invoke ARN of the lambda function for POST question"
}

output "delete_question_function_invoke_arn" {
  value       = aws_lambda_function.delete_question.invoke_arn
  description = "Invoke ARN of the lambda function for DELETE question"
}

output "put_question_function_invoke_arn" {
  value       = aws_lambda_function.put_question.invoke_arn
  description = "Invoke ARN of the lambda function for PUT question"
}
