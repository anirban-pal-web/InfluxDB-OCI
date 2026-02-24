resource "random_id" "suffix" {
  byte_length = 3
}

resource "aws_s3_bucket" "influx_backup" {
  bucket = "influxdb-backup-${random_id.suffix.hex}"

  force_destroy = true
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.influx_backup.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "enc" {
  bucket = aws_s3_bucket.influx_backup.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

