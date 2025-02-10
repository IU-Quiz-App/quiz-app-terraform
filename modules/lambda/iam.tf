resource "aws_iam_role" "lambda_execution_role" {
  name = "serverless_lambda_${var.stage}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"
    sid    = "AllowAccessToCloudWatchLogs"
    actions = [
      #      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    #TODO: Stärker einschränken
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging_policy" {
  name        = "lambda_logging_${var.stage}"
  path        = "/"
  description = "IAM policy for logging from a lambda function"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

data "aws_iam_policy_document" "lambda_access_dynamodb" {
  statement {
    effect = "Allow"
    sid    = "AllowAccessToDynamoDB"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Query"
    ]
    #TODO: Stärker einschränken
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_dynamodb_access_policy" {
  name        = "dynamodb_access_${var.stage}"
  path        = "/"
  description = "IAM policy for accessing DynamoDB from a lambda function"
  policy      = data.aws_iam_policy_document.lambda_access_dynamodb.json
}

resource "aws_iam_role_policy_attachment" "lambda_dynamodb_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_dynamodb_access_policy.arn
}
