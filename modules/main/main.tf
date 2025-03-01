module "s3" {
  source                      = "../s3"
  stage                       = var.stage
  cloudfront_distribution_arn = module.cloudfront.cloudfront_distribution_arn
}

module "acm" {
  source           = "../acm"
  domain           = var.domain
  hosted_zone_name = var.hosted_zone_name
}

module "api_gateway" {
  source                                     = "../api_gateway"
  stage                                      = var.stage
  domain                                     = var.domain
  certificate_arn                            = module.acm.certificate_arn
  get_question_function_invoke_arn           = module.lambda.get_question_function_invoke_arn
  get_questions_function_invoke_arn          = module.lambda.get_questions_function_invoke_arn
  post_question_function_invoke_arn          = module.lambda.post_question_function_invoke_arn
  delete_question_function_invoke_arn        = module.lambda.delete_question_function_invoke_arn
  put_question_function_invoke_arn           = module.lambda.put_question_function_invoke_arn
  get_game_session_function_invoke_arn       = module.lambda.get_game_session_function_invoke_arn
  get_game_sessions_function_invoke_arn      = module.lambda.get_game_sessions_function_invoke_arn
  create_game_session_function_invoke_arn    = module.lambda.create_game_session_function_invoke_arn
  start_game_session_function_invoke_arn     = module.lambda.start_game_session_function_invoke_arn
  answer_question_function_invoke_arn        = module.lambda.answer_question_function_invoke_arn
  get_next_game_question_function_invoke_arn = module.lambda.get_next_game_question_function_invoke_arn
  websocket_connect_function_invoke_arn      = module.lambda.websocket_connect_function_invoke_arn
  websocket_disconnect_function_invoke_arn   = module.lambda.websocket_disconnect_function_invoke_arn
}

module "lambda" {
  source                              = "../lambda"
  stage                               = var.stage
  domain                              = var.domain
  api_gateway_execution_arn           = module.api_gateway.api_gateway_execution_arn
  websocket_api_gateway_execution_arn = module.api_gateway.websocket_api_gateway_execution_arn
}

module "dynamodb" {
  source = "../dynamodb"
  stage  = var.stage
}

module "route53" {
  source                           = "../route53"
  domain                           = var.domain
  hosted_zone_name                 = var.hosted_zone_name
  gateway_domain_name              = module.api_gateway.gateway_domain_name
  gateway_hosted_zone_id           = module.api_gateway.gateway_hosted_zone_id
  websocket_gateway_domain_name    = module.api_gateway.websocket_gateway_domain_name
  websocket_gateway_hosted_zone_id = module.api_gateway.websocket_gateway_hosted_zone_id
  cloudfront_domain_name           = module.cloudfront.cloudfront_domain_name
  cloudfront_zone_id               = module.cloudfront.cloudfront_zone_id
}

module "cloudfront" {
  source                                  = "../cloudfront"
  stage                                   = var.stage
  s3_frontend_bucket_regional_domain_name = module.s3.s3_frontend_bucket_regional_domain_name
  domain                                  = var.domain
  us_east_certificate_arn                 = module.acm.certificate_us-east_arn
  log_bucket_id                           = module.s3.log_bucket_id
}
