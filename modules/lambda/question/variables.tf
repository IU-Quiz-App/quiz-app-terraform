variable "stage" {
  description = "Current stage"
  type        = string
}

variable "lambda_bucket_name" {
  description = "Name of the S3 bucket where lambda zip files are stored"
  type        = string
}

variable "lambda_execution_role_arn" {
  description = "ARN of the lambda execution role"
  type        = string
}

variable "get_question_s3_key" {
  description = "Path to the S3 object that contains the code for GET question"
  type        = string
  default     = "question/get-question.zip"
}

variable "api_gateway_execution_arn" {
  description = "ARN of the API Gateway"
  type        = string
}
