# modules/lambda/variables.tf
variable "lambda_name" { type = string }
variable "image_uri" { type = string }
variable "lambda_role_arn" { type = string }
variable "github_token" { type = string }
variable "repo_url" { type = string }
variable "s3_bucket_name" { type = string }
