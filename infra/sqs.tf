# sns.tf

resource "aws_sqs_queue" "rocket_project_sqs_queue" {
  name = var.aws_sqs_queue_name

  tags = {
    Project = var.project_name
    Environment = var.environment
  }
}

