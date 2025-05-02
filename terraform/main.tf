# Root main.tf file to call all modules for GitHub repo backup using Lambda

module "s3_backup" {
  source      = "./modules/s3"
  bucket_name = var.s3_bucket_name
}

module "iam_lambda" {
  source             = "./modules/iam"
  s3_bucket_arn      = module.s3_backup.bucket_arn
  s3_bucket_arn_full = module.s3_backup.bucket_arn_full
}

module "ecr_repo" {
  source    = "./modules/ecr"
  repo_name = var.ecr_repo_name
}

module "lambda_function" {
  source           = "./modules/lambda"
  lambda_name      = var.lambda_function_name
  image_uri        = var.lambda_image_uri
  lambda_role_arn  = module.iam_lambda.lambda_role_arn
  github_token     = var.github_token
  repo_url         = var.github_repo_url
  s3_bucket_name   = var.s3_bucket_name
}

module "eventbridge_schedule" {
  source              = "./modules/eventbridge"
  lambda_function_arn = module.lambda_function.lambda_arn
  lambda_function_name = module.lambda_function.lambda_name
  schedule_expression = var.schedule_expression
}



module "terraform_backend" {
  source              = "./modules/terraform_backend"
  backend_bucket_name = var.s3_bucket_name
  create_bucket       = false # if already exists
  lock_table_name     = var.lock_table_name
  environment         = var.environment

}
