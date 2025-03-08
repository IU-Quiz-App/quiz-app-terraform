variable "stage" {
  description = "Current stage"
  type        = string
}

#variable "start_game_session_function_arn" {
#  description = "ARN of the lambda function for PUT game session"
#  type        = string
#}

variable "send_next_question_function_arn" {
  description = "ARN of the lambda function to send the next question to players"
  type        = string
}

variable "check_complete_answers_function_arn" {
  description = "ARN of the lambda function to check if all players have answered"
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
