variable "stage" {
  description = "Current stage"
  type        = string
}

variable "us_east_certificate_arn" {
  description = "ARN of the ACM certificate"
  type        = string
}

variable "s3_frontend_bucket_regional_domain_name" {
  description = "Name of the frontend S3 bucket"
  type        = string
}

#variable "s3_frontend_bucket_website_endpoint" {
#  description = "Website endpoint of the frontend S3 bucket"
#  type        = string
#}

variable "log_bucket_id" {
  description = "Id of the logging bucket"
  type        = string
}

variable "domain" {
  description = "Domain name"
  type        = string
}
