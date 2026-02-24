output "bucket_name" {
  value = aws_s3_bucket.influx_backup.bucket
}

output "bucket_arn" {
  value = aws_s3_bucket.influx_backup.arn
}
