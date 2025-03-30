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

output "answer_question_function_invoke_arn" {
  value       = module.game.answer_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for POST answer question"
}

output "answer_question_function_arn" {
  value       = module.game.answer_question_function_arn
  description = "ARN of the lambda function for POST answer question"
}

output "get_next_game_question_function_invoke_arn" {
  value       = module.game.get_next_game_question_function_invoke_arn
  description = "Invoke ARN of the lambda function for GET next game question"
}

output "set_unanswered_questions_false_function_arn" {
  value       = module.game.set_unanswered_questions_false_function_arn
  description = "ARN of the lambda function to set unanswered questions to false"
}

output "save_task_token_function_arn" {
  value       = module.game.save_task_token_function_arn
  description = "ARN of the lambda function to save the task token of Wait for player answers state to DynamoDB"
}

output "websocket_connect_function_invoke_arn" {
  value       = module.websocket.websocket_connect_function_invoke_arn
  description = "Invoke ARN of the lambda function for websocket connect"
}

output "websocket_disconnect_function_invoke_arn" {
  value       = module.websocket.websocket_disconnect_function_invoke_arn
  description = "Invoke ARN of the lambda function for websocket disconnect"
}

output "update_websocket_information_function_invoke_arn" {
  value       = module.websocket.update_websocket_information_function_invoke_arn
  description = "Invoke ARN of the lambda function for updating websocket information"
}

output "send_question_function_arn" {
  value       = module.websocket_game.send_question_function_arn
  description = "ARN of the lambda function to send the question to players"
}

output "send_final_results_function_arn" {
  value       = module.websocket_game.send_final_results_function_arn
  description = "ARN of the lambda function to send the final results to players"
}

output "save_player_answer_function_invoke_arn" {
  value       = module.websocket_game.save_player_answer_function_invoke_arn
  description = "Invoke ARN of the lambda function for saving the answer of a player"
}

output "start_game_session_function_invoke_arn" {
  value       = module.websocket_game.start_game_session_function_arn
  description = "Invoke ARN of the lambda function to start the game session"
}

output "send_action_message_function_arn" {
  value       = module.websocket_game.send_action_message_function_arn
  description = "ARN of the lambda function to send the action message to players"
}
