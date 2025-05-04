variable "domain" {
  description = "Domain name"
  type        = string
}

variable "hosted_zone_name" {
  description = "Name of the hosted zone"
  type        = string
}

variable "stage" {
  description = "Current stage"
  type        = string
}
