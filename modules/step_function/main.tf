resource "aws_sfn_state_machine" "quiz_game_state_machine" {
  name     = "QuizGameStateMachine"
  role_arn = aws_iam_role.step_functions_role.arn

  definition = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "Start game",
  "States": {
    "Start game": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.start_game_session_function_arn}",
        "Payload": "{% $states.input %}"
      },
      "Next": "Send next question"
    },
    "Send next question": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "${var.send_next_question_function_arn}",
        "Payload": "{% $states.input %}"
      },
      "Next": "Parallel"
    },
    "Parallel": {
      "Type": "Parallel",
      "Branches": [
        {
          "StartAt": "Replace with StartExecution Child Step Function",
          "States": {
            "Replace with StartExecution Child Step Function": {
              "Type": "Pass",
              "End": true
            }
          }
        },
        {
          "StartAt": "Wait",
          "States": {
            "Wait": {
              "Type": "Wait",
              "Seconds": 60,
              "Next": "Check if all players answered"
            },
            "Check if all players answered": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Output": "{% $states.result.Payload %}",
              "Arguments": {
                "FunctionName": "${var.check_complete_answers_function_arn}",
                "Payload": "{% $states.input %}"
              },
              "Next": "All players answered"
            },
            "All players answered": {
              "Type": "Choice",
              "Choices": [
                {
                  "Condition": "{% $allPlayersAnswered %}",
                  "Next": "Pass"
                },
                {
                  "Condition": "{% $not($allPlayersAnswered) %}",
                  "Next": "Set unanswered questions to false"
                }
              ]
            },
            "Pass": {
              "Type": "Pass",
              "End": true
            },
            "Set unanswered questions to false": {
              "Type": "Task",
              "Resource": "arn:aws:states:::lambda:invoke",
              "Output": "{% $states.result.Payload %}",
              "Arguments": {
                "FunctionName": "arn:aws:lambda:eu-central-1:739275480216:function:get_question_dev:$LATEST",
                "Payload": "{% $states.input %}"
              },
              "End": true
            }
          }
        }
      ],
      "Next": "Check if last question is reached"
    },
    "Check if last question is reached": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "arn:aws:lambda:eu-central-1:739275480216:function:get_question_dev:$LATEST",
        "Payload": "{% $states.input %}"
      },
      "Next": "Last question reached"
    },
    "Last question reached": {
      "Type": "Choice",
      "Choices": [
        {
          "Condition": "{% $not($lastQuestionReached) %}",
          "Next": "Send next question"
        },
        {
          "Condition": "{% $lastQuestionReached %}",
          "Next": "Send result to players"          
        }
      ]
    },
    "Send result to players": {
      "Type": "Task",
      "Resource": "arn:aws:states:::lambda:invoke",
      "Output": "{% $states.result.Payload %}",
      "Arguments": {
        "FunctionName": "arn:aws:lambda:eu-central-1:739275480216:function:get_questions_dev:$LATEST",
        "Payload": "{% $states.input %}"
      },
      "End": true
    }
  },
  "QueryLanguage": "JSONata"
}
  EOF
}
