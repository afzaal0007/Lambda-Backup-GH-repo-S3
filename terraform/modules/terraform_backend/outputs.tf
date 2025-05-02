output "bucket_name" {
  value = var.create_bucket ? aws_s3_bucket.this[0].id : var.backend_bucket_name
}

output "bucket_arn" {
  value = var.create_bucket ? aws_s3_bucket.this[0].arn : null
}
output "dynamodb_table_name" {
  value = aws_dynamodb_table.tf_lock.name
}
