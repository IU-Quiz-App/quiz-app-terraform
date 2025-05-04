output "s3_frontend_bucket_regional_domain_name" {
  value       = aws_s3_bucket.s3_bucket_frontend.bucket_regional_domain_name
  description = "Name of the frontend S3 bucket"
}

output "log_bucket_id" {
  value       = aws_s3_bucket.log_bucket.id
  description = "Id of the logging bucket"
}
