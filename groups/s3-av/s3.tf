resource "aws_s3_bucket" "file_transfer_bucket" {
  bucket = var.file_transfer_bucket

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.file_transfer_encryption_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = local.tags
}

resource "aws_s3_bucket_public_access_block" "file_transfer_bucket_block" {
  bucket = aws_s3_bucket.file_transfer_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "file_transfer_bucket_ownership" {
  bucket = aws_s3_bucket.file_transfer_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "file_transfer_bucket_versioning" {
  bucket = aws_s3_bucket.file_transfer_bucket.id

  versioning_configuration {
    status = "Disabled"
  }
}
