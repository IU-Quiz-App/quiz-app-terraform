module "s3" {
  source = "../s3"
  stage  = var.stage
}

module "acm" {
  source           = "../acm"
  domain           = var.domain
  hosted_zone_name = var.hosted_zone_name
}

module "api_gateway" {
  source                           = "../api_gateway"
  stage                            = var.stage
  domain                           = var.domain
  certificate_arn                  = module.acm.certificate_arn
  api_gateway_cw_log_group_arn     = module.cloudwatch.api_gateway_cw_log_group_arn
  get_question_function_invoke_arn = module.lambda.get_question_function_invoke_arn
}

module "lambda" {
  source                    = "../lambda"
  stage                     = var.stage
  lambda_bucket_name        = module.s3.lambda_bucket_name
  api_gateway_execution_arn = module.api_gateway.api_gateway_execution_arn
}

module "cloudwatch" {
  source = "../cloudwatch"
  stage  = var.stage
}

module "route53" {
  source                                     = "../route53"
  domain                                     = var.domain
  hosted_zone_name                           = var.hosted_zone_name
  gateway_domain_name_cloudfront_domain_name = module.api_gateway.gateway_domain_name_cloudfront_domain_name
  gateway_domain_name_cloudfront_zone_id     = module.api_gateway.gateway_domain_name_cloudfront_zone_id
}
