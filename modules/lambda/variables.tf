variable "stage" {
  description = "Current stage"
  type        = string
}

variable "lambda_bucket_name" {
  description = "Name of the S3 bucket where lambda zip files are stored"
  type        = string
}

variable "api_gateway_execution_arn" {
  description = "ARN of the API Gateway"
  type        = string
}
