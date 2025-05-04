resource "aws_iam_role" "step_functions_role" {
  name = "step_functions_execution_role_${var.stage}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "step_functions_policy" {
  name        = "step_functions_execution_policy_${var.stage}"
  description = "Allows Step Functions to invoke Lambdas"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "lambda:InvokeFunction",
      Effect = "Allow",
      Resource = ["arn:aws:lambda:*:*:*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "step_functions_policy_attach" {
  role       = aws_iam_role.step_functions_role.name
  policy_arn = aws_iam_policy.step_functions_policy.arn
}
