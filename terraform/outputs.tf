# # outputs.tf
# output "lambda_function_arn" {
#   value = module.lambda_function.lambda_arn
# }

output "s3_backup_bucket" {
  value = module.s3_backup.bucket_name
}
