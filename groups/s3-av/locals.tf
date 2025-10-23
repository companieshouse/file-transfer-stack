locals {
  tags = {
    "Terraform"   = "true"
    "Bucket"      = var.file_transfer_bucket
    "Provisioned" = "file-transfer-stack"
  }
}
