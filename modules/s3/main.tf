module "s3_bucket_frontend" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.3.0"

  bucket     = "iu-quiz-frontend-${var.stage}"
  versioning = { enabled = true }
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}
