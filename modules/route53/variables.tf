variable "domain" {
  description = "Domain name"
  type        = string
}

variable "hosted_zone_name" {
  description = "Name of the hosted zone"
  type        = string
}

variable "gateway_domain_name" {
  description = "Domain name of the Backend API Gateway"
  type        = string
}

variable "gateway_hosted_zone_id" {
  description = "Zone ID of the Backend API Gateway"
  type        = string
}

variable "websocket_gateway_domain_name" {
  description = "Domain name of the Websocket API Gateway"
  type        = string
}

variable "websocket_gateway_hosted_zone_id" {
  description = "Zone ID of the Websocket API Gateway"
  type        = string
}

variable "cloudfront_domain_name" {
  description = "Name of the cloudfront domain that was created for frontend access"
  type        = string
}

variable "cloudfront_zone_id" {
  description = "Zone ID of the cloudfront domain that was created for frontend access"
  type        = string
}
