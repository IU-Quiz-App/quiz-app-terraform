data "archive_file" "lambda_save_player_answer_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../lambda-code/websocket_game/save-player-answer.py"
  output_path = "${path.module}/save_player_answer.zip"
}

resource "aws_lambda_function" "save_player_answer" {
  function_name    = "save_player_answer_${var.stage}"
  description      = "Save the answer of a player"
  handler          = "save-player-answer.lambda_handler"
  runtime          = "python3.13"
  architectures    = ["x86_64"]
  role             = var.lambda_execution_role_arn
  filename         = data.archive_file.lambda_save_player_answer_zip.output_path
  source_code_hash = data.archive_file.lambda_save_player_answer_zip.output_base64sha256
  timeout          = 10
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "INFO"
    log_group             = aws_cloudwatch_log_group.save_player_answer.name
  }

  environment {
    variables = {
      STAGE                          = var.stage,
      WEBSOCKET_API_GATEWAY_ENDPOINT = var.websocket_api_gateway_endpoint
    }
  }
  #TODO:
  #dead_letter_config {}
}

resource "aws_lambda_permission" "api_gw_trigger_save_player_answer_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.save_player_answer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.websocket_api_gateway_execution_arn}/*/*"
}
