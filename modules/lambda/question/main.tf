resource "aws_lambda_function" "get_question" {
  function_name = "get_question"
  description   = "Get a question"
  handler       = "main.lambda_handler"
  runtime       = "python3.13"
  architectures = ["x86_64"]
  role          = var.lambda_execution_role_arn
  s3_bucket     = var.lambda_bucket_name
  s3_key        = var.get_question_s3_key
  #source_code_hash = length(data.aws_s3_object.lambda_get_question) > 0 ? data.aws_s3_object.lambda_get_question[0].etag : ""
  #source_code_hash = try(data.aws_s3_object.lambda_get_question.etag, "")
  #source_code_hash = data.archive_file.bootstrap_lambda.output_base64sha256
  timeout = 10

  environment {
    variables = {
      STAGE = var.stage
    }
  }
  #  lifecycle {
  #    ignore_changes = [source_code_hash, ]
  #  }
  #TODO:
  #dead_letter_config {}
}

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_question.function_name
  principal     = "apigateway.amazonaws.com"

  #TODO: try -> source_arn = "${var.api_gateway_execution_arn}/question/GET"
  source_arn = "${var.api_gateway_execution_arn}/*/*"
}
