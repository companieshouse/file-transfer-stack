resource "aws_guardduty_malware_protection_plan" "protection_plan" {
  role = aws_iam_role.guard_duty_malware_protection_role.arn

  protected_resource {
    s3_bucket {
      bucket_name = aws_s3_bucket.file_transfer_bucket.bucket
    }
  }

  actions {
    tagging {
      status = "ENABLED"
    }
  }

  tags = local.tags
}
