variable "stage" {
  description = "Current stage"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "ARN of the lambda execution role"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "ARN of the API Gateway"
  type        = string
}
