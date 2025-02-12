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

variable "post_question_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for POST question"
  type        = string
}

variable "delete_question_function_invoke_arn" {
  description = "Invoke ARN of the lambda function for DELETE question"
  type        = string
}