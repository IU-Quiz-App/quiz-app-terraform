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
      "Next": "Game starts"
    },
    "Game starts": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_action_message_function_arn}",
        "Payload": {
          "game_session_uuid": "{% $game_session_uuid %}",
          "action_type": "quiz-started"
        }
      },
      "Next": "Wait until game starts"
    },
    "Wait until game starts": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "Send next question"
    },
    "Send next question": {
      "Type": "Task",
      "Comment": "Send next question to players",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_question_function_arn}",
        "Payload": {
          "game_session_uuid": "{% $game_session_uuid %}",
          "current_question_index": "{% $current_question_index %}",
          "action_type": "next-question"
        }
      },
      "Assign": {
        "current_question_uuid": "{% $states.result.Payload.body.current_question_uuid %}"
      },
      "Next": "Wait for player answers"
    },    
    "Wait for player answers": {
      "Type": "Task",
      "Comment": "Wait for players to answer the question",
      "Resource": "arn:aws:states:::lambda:invoke.waitForTaskToken",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.save_task_token_function_arn}",
        "Payload": {
          "game_session_uuid": "{% $game_session_uuid %}",
          "task_token": "{% $states.context.Task.Token %}"
        }
      },
      "TimeoutSeconds": 5,
      "Catch": [
        {
          "ErrorEquals": ["States.Timeout"],
          "Next": "Set unanswered questions to false"
        }
      ],
      "Next": "Question answered"
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
      "Next": "Question answered"
    },
    "Question answered": {
      "Type": "Task",
      "Comment": "Set questions to false/unanswered that were not answered by players",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_question_function_arn}",
        "Payload": {
          "game_session_uuid": "{% $game_session_uuid %}",
          "current_question_index": "{% $current_question_index %}",
          "action_type": "question-answered"
        }
      },
      "Assign": {
        "current_question_index": "{% $current_question_index + 1 %}"
      },
      "Next": "Last question reached"
    },
    "Last question reached": {
      "Type": "Choice",
      "Choices": [
        {
          "Condition": "{% $current_question_index != $quiz_length %}",
          "Next": "Next question incoming"
        },
        {
          "Condition": "{% $current_question_index = $quiz_length %}",
          "Next": "Quiz ended"          
        }
      ]
    },
    "Next question incoming": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_action_message_function_arn}",
        "Payload": {
          "game_session_uuid": "{% $game_session_uuid %}",
          "action_type": "next-question-incoming"
        }
      },
      "Next": "Wait until next question"
    },
    "Wait until next question": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "Send next question"
    },
    "Quiz ended": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_action_message_function_arn}",
        "Payload": {
          "game_session_uuid": "{% $game_session_uuid %}",
          "action_type": "quiz-ended"
        }
      },
      "Next": "Wait until results are sent"
    },
    "Wait until results are sent": {
      "Type": "Wait",
      "Seconds": 5,
      "Next": "Send result to players"
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
