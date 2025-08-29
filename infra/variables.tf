variable "aws_sqs_queue_name" {
  description = "The name of the SQS queue."
  type        = string
}

variable "project_name" {
  description = "The name of the project. Used for tagging resources."
  type        = string
}

variable "environment" {
  description = "The deployment environment (dev, prod, etc.)."
  type        = string
}

variable "aws_region" {
  description = "The AWS region to deploy the resources."
  type        = string
  default     = "sa-east-1"
}

variable "sns_topic_name" {
  description = "The name of the SNS topic."
  type        = string
}

variable "sns_topic_arn" {
  description = "O ARN do tópico SNS para assinatura."
  type        = string
}

variable "lambda_function_name" {
  description = "The name of the Lambda function."
  type        = string
}