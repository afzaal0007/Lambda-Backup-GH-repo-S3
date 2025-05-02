resource "aws_s3_bucket" "this" {
  count  = var.create_bucket ? 1 : 0
  bucket = var.backend_bucket_name

  force_destroy = true

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Name        = var.backend_bucket_name
    Environment = var.environment
  }
}

# aws_s3_bucket_versioning
resource "aws_s3_bucket_versioning" "this" {
  count  = var.create_bucket ? 1 : 0
  bucket = aws_s3_bucket.this[0].id

  versioning_configuration {
    status = "Enabled"
  }
}




resource "aws_dynamodb_table" "tf_lock" {
  name         = var.lock_table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }


  tags = {
    Name        = var.lock_table_name
    Environment = var.environment
  }
}












