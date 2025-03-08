output "game_step_function_arn" {
  description = "ARN of the game step function"
  value       = aws_sfn_state_machine.game_state_machine.arn
}
