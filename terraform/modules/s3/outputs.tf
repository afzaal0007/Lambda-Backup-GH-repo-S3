# modules/s3/outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.this.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "bucket_arn_full" {
  value = "${aws_s3_bucket.this.arn}/*"
}
