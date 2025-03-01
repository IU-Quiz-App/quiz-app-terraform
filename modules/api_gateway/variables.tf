variable "domain" {
  description = "Domain name"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
}

variable "stage" {
  description = "Current stage"
  type        = string
}

variable "get_question_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for GET question"
  type        = string
}

variable "get_questions_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for GET list of questions"
  type        = string
}

variable "post_question_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for POST question"
  type        = string
}

variable "delete_question_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for DELETE question"
  type        = string
}

variable "put_question_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for PUT question"
  type        = string
}

variable "get_game_session_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for GET game session"
  type        = string
}

variable "get_game_sessions_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for GET list of game sessions"
  type        = string
}

variable "create_game_session_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for POST game session"
  type        = string
}

variable "start_game_session_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for PUT game session"
  type        = string
}

variable "answer_question_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for POST answer question"
  type        = string
}

variable "get_next_game_question_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for GET next game question"
  type        = string
}

variable "websocket_connect_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for websocket connect"
  type        = string
}

variable "websocket_disconnect_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for websocket disconnect"
  type        = string
}
