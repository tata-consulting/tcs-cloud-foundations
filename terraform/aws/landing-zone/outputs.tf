output "log_bucket_name" {
  description = "Centralized log bucket name."
  value       = aws_s3_bucket.logs.bucket
}
