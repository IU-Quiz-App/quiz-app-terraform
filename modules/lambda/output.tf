output "get_question_function_invoke_arn" {
  value       = module.questions.get_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET question"
}
