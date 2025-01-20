output "api_gateway_execution_arn" {
  value       = aws_apigatewayv2_api.api_gateway.execution_arn
  description = "ARN of the API Gateway"
}

output "gateway_domain_name_cloudfront_domain_name" {
  value       = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].target_domain_name
  description = "Name of the cloudfront domain that was created for API Gateway"
}

output "gateway_domain_name_cloudfront_zone_id" {
  value       = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].hosted_zone_id
  description = "Zone ID of the cloudfront domain that was created for API Gateway"
}
