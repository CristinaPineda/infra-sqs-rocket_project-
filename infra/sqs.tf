resource "aws_sqs_queue" "rocket_project_sqs" {
  name = var.aws_sqs_queue_name

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_sqs_queue_policy" "rocket_project_sqs_policy" {
  queue_url = aws_sqs_queue.rocket_project_sqs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "sqs_policy_for_sns",
    Statement = [
      {
        Sid    = "AllowSNSTopicToPublish",
        Effect = "Allow",
        Principal = {
          Service = "sns.amazonaws.com"
        },
        Action = "sqs:SendMessage",
        Resource = aws_sqs_queue.rocket_project_sqs.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = var.sns_topic_arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "sns_sqs_subscription" {
  topic_arn = var.sns_topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.rocket_project_sqs.arn
}


# Política da fila que permite que a sua Lambda leia da fila
resource "aws_sqs_queue_policy" "lambda_permission" {
  queue_url = aws_sqs_queue.rocket_project_sqs.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "sqs-access-policy-for-lambda",
    Statement = [
      {
        Sid = "LambdaAccess",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        },
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Resource = aws_sqs_queue.source_queue.arn,
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = "arn:aws:lambda:${var.aws_region}:${data.aws_caller_identity.current.account_id}:function:${var.lambda_function_name}"
          }
        }
      }
    ]
  })
}