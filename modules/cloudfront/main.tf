resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "s3-origin-access-control-${var.stage}"
  description                       = "OAC for S3-CloudFront-Access"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend-distribution" {
  origin {
    domain_name = var.s3_frontend_bucket_regional_domain_name
    #domain_name = var.s3_frontend_bucket_website_endpoint
    origin_id                = "S3-Origin-${var.stage}"
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
    #    custom_origin_config {
    #      http_port              = 80
    #      https_port             = 443
    #      origin_protocol_policy = "http-only"
    #      origin_ssl_protocols   = ["TLSv1.2"]
    #    }
  }

  enabled             = true
  is_ipv6_enabled     = false
  default_root_object = "index.html"

  logging_config {
    bucket          = "${var.log_bucket_id}.s3.amazonaws.com"
    prefix          = "cloudfront-logs/"
    include_cookies = false
  }

  aliases = [var.domain, "www.${var.domain}"]

  viewer_certificate {
    acm_certificate_arn      = var.us_east_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  price_class = "PriceClass_100" #only in USA and EU for lowest pricing

  default_cache_behavior {
    target_origin_id       = "S3-Origin-${var.stage}"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id
    compress               = true
    #    origin_request_policy_id = CORS_S3_ORIGIN
  }
  custom_error_response {
    error_code            = 403
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 300
  }

  custom_error_response {
    error_code            = 404
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 300
  }
}

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}
