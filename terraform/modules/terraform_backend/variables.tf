variable "backend_bucket_name" {
  type        = string
  description = "Name of the S3 bucket for Terraform state"
}

variable "lock_table_name" {
  type        = string
  description = "Name of the DynamoDB table for Terraform state locking"
}

variable "environment" {
  type        = string
  description = "Environment tag"
  default     = "dev"
}


variable "create_bucket" {
  type        = bool
  description = "Whether to create the bucket or treat it as external"
  default     = false
}
