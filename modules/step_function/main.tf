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
      "Comment": "Send information to frontend that the game starts",
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
      "Comment": "Wait for countdown to start the game",
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
      "Comment": "Send information to frontend that all players have answered the question",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_action_message_function_arn}",
        "Payload": {
          "game_session_uuid": "{% $game_session_uuid %}",
          "action_type": "question-answered"
        }
      },
      "Next": "Countdown to show answer"
    },
    "Countdown to show answer": {
      "Type": "Wait",
      "Comment": "Wait for countdown to show the correct answer",
      "Seconds": 5,
      "Next": "Correct answer"
    },
    "Correct answer": {
      "Type": "Task",
      "Comment": "Send the question with the correct answer to the players",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_question_function_arn}",
        "Payload": {
          "game_session_uuid": "{% $game_session_uuid %}",
          "current_question_index": "{% $current_question_index %}",
          "action_type": "correct-answer"
        }
      },
      "Assign": {
        "current_question_index": "{% $current_question_index + 1 %}"
      },
      "Next": "Let players check correct answer"
    },
    "Let players check correct answer": {
      "Type": "Wait",
      "Comment": "Let players check the the correct answer",
      "Seconds": 5,
      "Next": "Last question reached"
    },
    "Last question reached": {
      "Type": "Choice",
      "Comment": "Check if the last question is reached",
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
      "Comment": "Send information to frontend that the next question will be sent",
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
      "Comment": "Wait for countdown to show the next question",
      "Seconds": 5,
      "Next": "Send next question"
    },
    "Quiz ended": {
      "Type": "Task",
      "Comment": "Send information to frontend that all questions are answered",
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
      "Comment": "Wait for countdown to show the final results",
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
