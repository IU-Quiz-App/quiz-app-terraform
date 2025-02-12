output "get_question_function_invoke_arn" {
  value       = module.question.get_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET question"
}

output "post_question_function_invoke_arn" {
  value       = module.question.post_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for POST question"
}

output "delete_question_function_invoke_arn" {
  value       = module.question.delete_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for DELETE question"
}
