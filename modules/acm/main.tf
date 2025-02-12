module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name = var.domain
  zone_id     = data.aws_route53_zone.hosted_zone.zone_id

  create_certificate                 = true
  create_route53_records             = true
  validation_method                  = "DNS"
  validation_allow_overwrite_records = true
  dns_ttl                            = 30

  subject_alternative_names = [
    "api.${var.domain}",
    "www.${var.domain}"
  ]

  wait_for_validation = true
}

module "acm_us_east" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  providers = {
    aws = aws.us-east-1 # Use different provider as cert must be in us-east-1
  }

  domain_name = var.domain
  zone_id     = data.aws_route53_zone.hosted_zone.zone_id

  create_certificate                 = true
  create_route53_records             = true
  validation_method                  = "DNS"
  validation_allow_overwrite_records = true
  dns_ttl                            = 30

  subject_alternative_names = [
    "api.${var.domain}",
    "www.${var.domain}"
  ]

  wait_for_validation = true
}
