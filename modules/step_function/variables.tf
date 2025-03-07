variable "stage" {
  description = "Current stage"
  type        = string
}

variable "start_game_session_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for PUT game session"
  type        = string
}

variable "send_next_question_function_invoke_arn" {
  description = "Invoke ARN of the lambda function to send the next question to players"
  type        = string
}
