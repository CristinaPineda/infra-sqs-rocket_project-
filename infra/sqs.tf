# 1. Recurso da Dead-Letter Queue (DLQ)
resource "aws_sqs_queue" "dlq" {
  name                      = "${var.project_name}-${var.environment}-sqs-dlq"
  message_retention_seconds = 1209600 # 14 dias
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# 2. Modifica a fila SQS principal para incluir a DLQ
resource "aws_sqs_queue" "rocket_project_sqs" {
  name = var.aws_sqs_queue

  # Adiciona a política de redirecionamento para a DLQ
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# 3. Política de acesso à fila
resource "aws_sqs_queue_policy" "rocket_project_sqs_policy" {
  queue_url = aws_sqs_queue.rocket_project_sqs.id

  policy = jsonencode({
    Version = "2012-10-17",
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
          },
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
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
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
  })
}

# 4. Assinatura do Tópico SNS
resource "aws_sns_topic_subscription" "sns_sqs_subscription" {
  topic_arn = var.sns_topic_arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.rocket_project_sqs.arn
}

# Data source
data "aws_caller_identity" "current" {}