#module "s3_bucket_frontend" {
#  source  = "terraform-aws-modules/s3-bucket/aws"
#  version = "4.3.0"
#
#  bucket     = "iu-quiz-frontend-${var.stage}"
#  versioning = { enabled = true }
#  server_side_encryption_configuration = {
#    rule = {
#      apply_server_side_encryption_by_default = {
#        sse_algorithm = "AES256"
#      }
#    }
#  }
#}

resource "aws_s3_bucket" "s3_bucket_frontend" {
  bucket = "iu-quiz-frontend-${var.stage}"
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_frontend_public_access" {
  bucket = aws_s3_bucket.s3_bucket_frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "static_site_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket_frontend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.s3_bucket_frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "${var.cloudfront_distribution_arn}"
          }
        }
      },
      {
        Effect    = "Allow"
        Principal = { Service = "cloudfront.amazonaws.com" }
        Action    = "s3:ListBucket"
        Resource  = "${aws_s3_bucket.s3_bucket_frontend.arn}"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = "${var.cloudfront_distribution_arn}"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_versioning" "static_site_bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket_frontend.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = "iu-quiz-logs-${var.stage}"
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  bucket = aws_s3_bucket.s3_bucket_frontend.id

  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "s3-logs/"
}

resource "aws_s3_bucket_ownership_controls" "object_ownership" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_logging_acl" {
  bucket = aws_s3_bucket.log_bucket.id

  access_control_policy {
    grant {
      grantee {
        type = "CanonicalUser"
        # Canonical User ID for awslogsdelivery
        id = "3ef86153c365da94739ba7f60ab2cd6414a897915797c533813710275ca568e6"
      }
      permission = "FULL_CONTROL"
    }
    grant {
      grantee {
        type = "CanonicalUser"
        # Canonical User ID for Account
        id = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
      }
      permission = "FULL_CONTROL"
    }

    owner {
      id = data.aws_canonical_user_id.current.id
    }

  }
}

resource "aws_s3_bucket_policy" "cloudfront_logging_policy" {
  bucket = aws_s3_bucket.log_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:PutObject"
        Resource  = "arn:aws:s3:::iu-quiz-logs-dev/*"
        Condition = {
          StringEquals = {
            "AWS:SourceAccount" = "${data.aws_caller_identity.current.account_id}"
          }
        }
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::iu-quiz-logs-dev/*"
        Condition = {
          StringEquals = {
            "aws:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${var.cloudfront_distribution_arn}"
          }
        }
      }
    ]
  })
}

data "aws_caller_identity" "current" {}
data "aws_canonical_user_id" "current" {}
