data "aws_route53_zone" "zone" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "backend" {
  name    = "api.${var.domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.zone.id

  alias {
    name                   = var.gateway_domain_name
    zone_id                = var.gateway_hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "frontend" {
  name    = var.domain
  type    = "A"
  zone_id = data.aws_route53_zone.zone.id

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "frontend_www" {
  name    = "www.${var.domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.zone.id

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
