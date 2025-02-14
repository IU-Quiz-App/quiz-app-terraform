module "question" {
  source                    = "./question"
  stage                     = var.stage
  domain                    = var.domain
  lambda_execution_role_arn = aws_iam_role.lambda_execution_role.arn
  api_gateway_execution_arn = var.api_gateway_execution_arn
}
