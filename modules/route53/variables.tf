variable "domain" {
  description = "Domain name"
  type        = string
}

variable "hosted_zone_name" {
  description = "Name of the hosted zone"
  type        = string
}

variable "gateway_domain_name_cloudfront_domain_name" {
  description = "Name of the cloudfront domain that was created for API Gateway"
  type        = string
}

variable "gateway_domain_name_cloudfront_zone_id" {
  description = "Zone ID of the cloudfront domain that was created for API Gateway"
  type        = string
}
