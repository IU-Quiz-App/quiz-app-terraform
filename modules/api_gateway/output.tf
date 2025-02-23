output "api_gateway_execution_arn" {
  value       = aws_apigatewayv2_api.api_gateway.execution_arn
  description = "ARN of the Backend API Gateway"
}

output "gateway_domain_name" {
  value       = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].target_domain_name
  description = "Domain name of the Backend API Gateway"
}

output "gateway_hosted_zone_id" {
  value       = aws_apigatewayv2_domain_name.domain_name.domain_name_configuration[0].hosted_zone_id
  description = "Zone ID of the Backend API Gateway"
}

output "websocket_api_gateway_execution_arn" {
  value       = aws_apigatewayv2_api.websocket_api_gateway.execution_arn
  description = "ARN of the Websocket API Gateway"
}

output "websocket_gateway_domain_name" {
  value       = aws_apigatewayv2_domain_name.websocket_domain_name.domain_name_configuration[0].target_domain_name
  description = "Domain name of the Websocket API Gateway"
}

output "websocket_gateway_hosted_zone_id" {
  value       = aws_apigatewayv2_domain_name.websocket_domain_name.domain_name_configuration[0].hosted_zone_id
  description = "Zone ID of the Websocket API Gateway"
}
