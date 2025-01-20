# Dummy data for initial creation of lambda functions
resource "aws_s3_object" "dummy_lambda_code" {
  bucket = var.lambda_bucket_name
  key    = var.get_question_s3_key
  source = "${path.module}/../dummy-function.zip"

  #count = length(data.aws_s3_object.lambda_get_question) == 0 ? 1 : 0
}

#data "archive_file" "lambda" {
#  type = "zip"
#  #source_file = "./dummy-function.py"
#  output_path = "${path.module}/dummy_function.zip"
#  source {
#    content  = file("${path.root}/modules/lambda/dummy-function.py")
#    filename = "lambda_function.py"
#  }
#}
