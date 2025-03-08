variable "stage" {
  description = "Current stage"
  type        = string
}

variable "send_next_question_function_arn" {
  description = "ARN of the lambda function to send the next question to players"
  type        = string
}

variable "send_final_results_function_arn" {
  description = "ARN of the lambda function to send the final results to players"
  type        = string
}

variable "set_unanswered_questions_false_function_arn" {
  description = "ARN of the lambda function to set unanswered questions to false"
  type        = string
}
