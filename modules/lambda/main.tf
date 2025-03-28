module "question" {
  source                    = "./question"
  stage                     = var.stage
  domain                    = var.domain
  lambda_execution_role_arn = aws_iam_role.lambda_execution_role.arn
  api_gateway_execution_arn = var.api_gateway_execution_arn
}

module "game" {
  source                    = "./game"
  stage                     = var.stage
  domain                    = var.domain
  lambda_execution_role_arn = aws_iam_role.lambda_execution_role.arn
  api_gateway_execution_arn = var.api_gateway_execution_arn
}

module "websocket" {
  source                              = "./websocket"
  stage                               = var.stage
  domain                              = var.domain
  lambda_execution_role_arn           = aws_iam_role.lambda_execution_role.arn
  websocket_api_gateway_execution_arn = var.websocket_api_gateway_execution_arn
}

module "websocket_game" {
  source                              = "./websocket_game"
  stage                               = var.stage
  domain                              = var.domain
  lambda_execution_role_arn           = aws_iam_role.lambda_execution_role.arn
  websocket_api_gateway_execution_arn = var.websocket_api_gateway_execution_arn
  websocket_api_gateway_endpoint      = var.websocket_api_gateway_endpoint
  game_step_function_arn              = var.game_step_function_arn
}
