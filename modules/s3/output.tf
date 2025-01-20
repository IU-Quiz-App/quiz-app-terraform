output "lambda_bucket_name" {
  value       = module.s3_bucket_lambda_functions.s3_bucket_id
  description = "Name of the S3 bucket where lambda zip files are stored"
}
