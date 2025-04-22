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
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
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
      "dynamodb:BatchGetItem",
      "dynamodb:BatchWriteItem",
      "dynamodb:ConditionCheckItem",
      "dynamodb:PutItem",
      "dynamodb:DescribeTable",
      "dynamodb:DeleteItem",
      "dynamodb:GetItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "dynamodb:UpdateItem",
      "dynamodb:DescribeStream",
      "dynamodb:GetRecords",
      "dynamodb:GetShardIterator",
      "dynamodb:ListStreams"
    ]
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

data "aws_iam_policy_document" "manage-connections" {
  statement {
    effect    = "Allow"
    sid       = "AllowManageConnections"
    actions   = ["execute-api:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "manage-connections-policy" {
  name   = "manage_websocket_connections_${var.stage}"
  policy = data.aws_iam_policy_document.manage-connections.json
}

resource "aws_iam_role_policy_attachment" "lambda_manage_connections" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.manage-connections-policy.arn
}

data "aws_iam_policy_document" "lambda_access_step_function" {
  statement {
    effect = "Allow"
    sid    = "AllowAccessToStepFunctions"
    actions = [
      "states:StartExecution",
      "states:DescribeExecution",
      "states:ListExecutions",
      "states:ListStateMachines",
      "states:DescribeStateMachine",
      "states:SendTaskSuccess"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_access_step_function_policy" {
  name        = "access_step_function_${var.stage}"
  path        = "/"
  description = "IAM policy for accessing Step Functions from a lambda function"
  policy      = data.aws_iam_policy_document.lambda_access_step_function.json
}

resource "aws_iam_role_policy_attachment" "lambda_access_step_function" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_access_step_function_policy.arn
}

data "aws_iam_policy_document" "lambda_invoke_lambda" {
  statement {
    effect = "Allow"
    sid    = "AllowInvokeLambda"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "lambda_invoke_lambda_policy" {
  name        = "invoke_lambda_${var.stage}"
  path        = "/"
  description = "IAM policy for invoking other lambda functions"
  policy      = data.aws_iam_policy_document.lambda_invoke_lambda.json
}

resource "aws_iam_role_policy_attachment" "lambda_invoke_lambda" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = aws_iam_policy.lambda_invoke_lambda_policy.arn
}
