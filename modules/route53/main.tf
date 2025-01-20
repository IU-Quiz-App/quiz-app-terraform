data "aws_route53_zone" "zone" {
  name = var.hosted_zone_name
}

resource "aws_route53_record" "example" {
  name    = "api.${var.domain}"
  type    = "A"
  zone_id = data.aws_route53_zone.zone.id

  alias {
    name                   = var.gateway_domain_name_cloudfront_domain_name
    zone_id                = var.gateway_domain_name_cloudfront_zone_id
    evaluate_target_health = false
  }
}
