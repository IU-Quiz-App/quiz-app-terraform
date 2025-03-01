variable "stage" {
  description = "Current stage"
  type        = string
}

variable "domain" {
  description = "Domain name"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "ARN of the lambda execution role"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "ARN of the Websocket API Gateway"
  type        = string
}
