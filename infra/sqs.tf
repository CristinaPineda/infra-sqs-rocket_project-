# 1. DATA SOURCE: Busca o tópico SNS existente
# O Terraform vai procurar por um tópico com o nome especificado.
data "aws_sns_topic" "sns_topic" {
  name = var.sns_topic_name
}

# 2. Cria a fila SQS
# O nome da fila foi corrigido para usar a variável 'aws_sqs_queue_name'
resource "aws_sqs_queue" "sns_target_queue" {
  name = var.aws_sqs_queue_name

  tags = {
    Project = var.project_name
    Environment = var.environment
  }
}
# 3. Cria a política de permissões para a fila SQS
# Esta política permite que o tópico SNS envie mensagens para esta fila.
resource "aws_sqs_queue_policy" "sns_sqs_policy" {
  queue_url = aws_sqs_queue.sns_target_queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action    = "sqs:SendMessage"
        Resource  = aws_sqs_queue.sns_target_queue.arn
        Condition = {
          ArnEquals = {
            # Usa o ARN do tópico SNS obtido pelo Data Source
            "aws:SourceArn" = data.aws_sns_topic.sns_topic.arn
          }
        }
      }
    ]
  })
}

# 4. Cria a assinatura que conecta o tópico SNS à fila SQS
# Esta é a parte que finaliza a conexão entre os dois serviços.
resource "aws_sns_topic_subscription" "sns_queue_subscription" {
  # Usa o ARN do tópico SNS obtido pelo Data Source
  topic_arn = data.aws_sns_topic.sns_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sns_target_queue.arn
}