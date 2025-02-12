output "cloudfront_distribution_arn" {
  value       = aws_cloudfront_distribution.frontend-distribution.arn
  description = "ARN of the CloudFront distribution"
}

output "cloudfront_zone_id" {
  value       = aws_cloudfront_distribution.frontend-distribution.hosted_zone_id
  description = "Zone ID of the cloudfront domain that was created for frontend access"
}

output "cloudfront_domain_name" {
  value       = aws_cloudfront_distribution.frontend-distribution.domain_name
  description = "Name of the cloudfront domain that was created for frontend access"
}
