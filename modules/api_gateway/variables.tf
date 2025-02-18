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

variable "api_gateway_cw_log_group_arn" {
  description = "ARN of the CloudWatch LogGroup for the API Gateway"
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
