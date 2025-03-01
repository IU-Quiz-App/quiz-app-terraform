output "get_question_function_invoke_arn" {
  value       = module.question.get_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET question"
}

output "get_questions_function_invoke_arn" {
  value       = module.question.get_questions_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET list of questions"
}

output "post_question_function_invoke_arn" {
  value       = module.question.post_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for POST question"
}

output "delete_question_function_invoke_arn" {
  value       = module.question.delete_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for DELETE question"
}

output "put_question_function_invoke_arn" {
  value       = module.question.put_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for PUT question"
}

output "get_game_session_function_invoke_arn" {
  value       = module.game.get_game_session_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET game session"
}

output "get_game_sessions_function_invoke_arn" {
  value       = module.game.get_game_sessions_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET list of game sessions"
}

output "create_game_session_function_invoke_arn" {
  value       = module.game.create_game_session_function_invoke_arn
  description = "Invoke ARN of the lambda function for POST game session"
}

output "start_game_session_function_invoke_arn" {
  value       = module.game.start_game_session_function_invoke_arn
  description = "Invoke ARN of the lambda function for PUT game session"
}

output "answer_question_function_invoke_arn" {
  value       = module.game.answer_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for POST answer question"
}

output "get_next_game_question_function_invoke_arn" {
  value       = module.game.get_next_game_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET next game question"
}

output "websocket_connect_function_invoke_arn" {
  value       = module.websocket.websocket_connect_function_invoke_arn
  description = "Invoke ARN of the lambda function for websocket connect"
}

output "websocket_disconnect_function_invoke_arn" {
  value       = module.websocket.websocket_disconnect_function_invoke_arn
  description = "Invoke ARN of the lambda function for websocket disconnect"
}
