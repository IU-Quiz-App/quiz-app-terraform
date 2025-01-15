data "aws_route53_zone" "hosted_zone" {
  name         = "${var.domain}."
  private_zone = false
}
