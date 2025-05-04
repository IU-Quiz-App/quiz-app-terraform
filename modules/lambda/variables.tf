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

variable "websocket_api_gateway_execution_arn" {
  description = "ARN of the Websocket API Gateway"
  type        = string
}

variable "websocket_api_gateway_endpoint" {
  description = "Endpoint of the Websocket API Gateway"
  type        = string
}

variable "game_step_function_arn" {
  description = "ARN of the game step function"
  type        = string
}
