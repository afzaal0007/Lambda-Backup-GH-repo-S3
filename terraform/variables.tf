# variables.tf
variable "aws_region" {

}

variable "s3_bucket_name" {
  description = "Name of the S3 bucket for backups"
}

variable "ecr_repo_name" {
  description = "ECR repo name for Lambda image"

}

variable "lambda_function_name" {
  description = "Name of the Lambda function"

}

variable "lambda_image_uri" {
  description = "URI of the Lambda container image in ECR"
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repo URL to clone"
}

variable "schedule_expression" {
  description = "CloudWatch cron expression"

}

variable "lock_table_name" {
  description = "Name of the DynamoDB table for Terraform state locking"


}

variable "environment" {
  description = "Environment tag"


}