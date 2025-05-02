# ------------------------
# modules/lambda/main.tf
# ------------------------
resource "aws_lambda_function" "this" {
  function_name = var.lambda_name
  package_type  = "Image"
  image_uri     = var.image_uri
  role          = var.lambda_role_arn
  timeout       = 300
  memory_size   = 512

  environment {
    variables = {
      GITHUB_TOKEN = var.github_token
      REPO_URL     = var.repo_url
      S3_BUCKET    = var.s3_bucket_name
    }
  }
}