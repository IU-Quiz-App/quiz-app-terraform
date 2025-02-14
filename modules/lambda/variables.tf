variable "stage" {
  description = "Current stage"
  type        = string
}

variable "domain" {
  description = "Domain name"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "ARN of the API Gateway"
  type        = string
}
