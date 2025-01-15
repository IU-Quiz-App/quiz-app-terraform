module "s3" {
  source = "../s3"
  stage  = var.stage
}

module "acm" {
  source = "../acm"
  domain = var.domain
}

module "api_gateway" {
  source          = "../api_gateway"
  domain          = var.domain
  certificate_arn = module.acm.certificate_arn
}
