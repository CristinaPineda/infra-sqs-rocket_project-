output "sqs_queue_arn" {
  description = "The ARN of the SQS queue."
  value       = aws_sqs_queue.rocket_project_sqs.arn
}

output "sqs_queue_name" {
  description = "The name of the SQS queue."
  value       = aws_sqs_queue.rocket_project_sqs.name
}