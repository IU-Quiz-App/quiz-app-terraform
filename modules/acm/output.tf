output "certificate_arn" {
  value       = module.acm.acm_certificate_arn
  description = "ARN of the ACM certificate"
}

output "certificate_us-east_arn" {
  value       = module.acm_us_east.acm_certificate_arn
  description = "ARN of the us east ACM certificate"
}
