resource "aws_kms_key" "file_transfer_encryption_key" {
  description             = "Encrypt user uploaded files for ${var.file_transfer_type}"
  deletion_window_in_days = 30
  policy                  = data.aws_iam_policy_document.kms_key_policy.json
  enable_key_rotation     = true

  tags = local.tags
}

resource "aws_kms_alias" "file_transfer_encryption_key_alias" {
  name          = var.file_transfer_kms_alias
  target_key_id = aws_kms_key.file_transfer_encryption_key.key_id
}
