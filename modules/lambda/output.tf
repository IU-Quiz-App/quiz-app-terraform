output "get_question_function_invoke_arn" {
  value       = module.question.get_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET question"
}

output "get_questions_function_invoke_arn" {
  value       = module.question.get_questions_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET list of questions"
}

output "post_question_function_invoke_arn" {
  value       = module.question.post_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for POST question"
}

output "delete_question_function_invoke_arn" {
  value       = module.question.delete_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for DELETE question"
}

output "put_question_function_invoke_arn" {
  value       = module.question.put_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for PUT question"
}
