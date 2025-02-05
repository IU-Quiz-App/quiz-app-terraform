output "get_question_function_invoke_arn" {
  value       = module.questions.get_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET question"
}

output "post_question_function_invoke_arn" {
  value       = module.questions.post_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for POST question"
}
