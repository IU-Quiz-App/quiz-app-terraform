output "api_gateway_cw_log_group_arn" {
  value       = aws_cloudwatch_log_group.api_gw.arn
  description = "ARN of the CloudWatch LogGroup for the API Gateway"
}
