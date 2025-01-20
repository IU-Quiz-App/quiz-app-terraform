module "questions" {
  source                    = "./question"
  stage                     = var.stage
  lambda_bucket_name        = var.lambda_bucket_name
  lambda_execution_role_arn = aws_iam_role.lambda_execution_role.arn
  api_gateway_execution_arn = var.api_gateway_execution_arn
}
