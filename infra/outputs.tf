output "sqs_arn" {
  description = "The ARN of the SQS queue."
  value       = aws_sqs_queue.sns_target_queue.arn
}

output "sqs_queue_name" {
  description = "The name of the SQS queue."
  value       = aws_sqs_queue.sns_target_queue.name
}