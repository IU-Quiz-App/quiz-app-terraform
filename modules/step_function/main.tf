resource "aws_sfn_state_machine" "game_state_machine" {
  name     = "QuizGameStateMachine"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "Set global variables",
  "States": {
    "Set global variables": {
      "Type": "Pass",
      "Comment": "Set global variables",
      "Assign": {
        "game_session_uuid": "{% $states.input.game_session_uuid %}",
        "quiz_length": "{% $states.input.quiz_length %}",
        "current_question_index": "{% 0 %}"
      },
      "Next": "Send next question"
    },
    "Send next question": {
      "Type": "Task",
      "Comment": "Send next question to players",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_next_question_function_arn}",
        "Payload": {
          "game_session_uuid": "{% $game_session_uuid %}",
          "current_question_index": "{% $current_question_index %}"
        }
      },
      "Assign": {
        "current_question_index": "{% $current_question_index + 1 %}",
        "current_question_uuid": "{% $states.result.Payload.body.current_question_uuid %}"
      },
      "Next": "Wait for player answers"
    },    
    "Wait for player answers": {
      "Type": "Task",
      "Comment": "Wait for players to answer the question",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_final_results_function_arn}",
        "Payload": "{% $states.input %}"
      },
      "TimeoutSeconds": 5,
      "Catch": [
        {
          "ErrorEquals": ["States.Timeout"],
          "Next": "Set unanswered questions to false"
        }
      ],
      "Next": "Last question reached"
    },
    "Set unanswered questions to false": {
      "Type": "Task",
      "Comment": "Set questions to false/unanswered that were not answered by players",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.set_unanswered_questions_false_function_arn}",
        "Payload": {
          "game_session_uuid": "{% $game_session_uuid %}",
          "current_question_uuid": "{% $current_question_uuid %}"
        }
      },
      "Next": "Last question reached"
    },
    "Last question reached": {
      "Type": "Choice",
      "Choices": [
        {
          "Condition": "{% $current_question_index != $quiz_length %}",
          "Next": "Send next question"
        },
        {
          "Condition": "{% $current_question_index = $quiz_length %}",
          "Next": "Send result to players"          
        }
      ]
    },
    "Send result to players": {
      "Type": "Task",
      "Comment": "Send final game results to players",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_final_results_function_arn}",
        "Payload": "{% $states.input %}"
      },
      "End": true
    }
  },
  "QueryLanguage": "JSONata"
}
  EOF
}
