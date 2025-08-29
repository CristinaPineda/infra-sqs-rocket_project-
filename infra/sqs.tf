resource "aws_sqs_queue" "rocket_project_sqs" {
  name = var.aws_sqs_queue

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
          # Boa prática de segurança: garante que a origem é do seu tópico E da sua conta
          ArnEquals = {
            "aws:SourceArn" = var.sns_topic_arn
          },
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
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

data "aws_caller_identity" "current" {}

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
        Resource = aws_sqs_queue.rocket_project_sqs.arn,
        Condition = {
          # Use o ID da sua conta como condição de segurança
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}