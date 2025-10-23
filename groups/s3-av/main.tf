terraform {
  backend "s3" {}
  required_version = ">= 1.3, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "aws" {}

module "s3_access_logging" {
  source = "git@github.com:companieshouse/terraform-modules//aws/s3_access_logging?ref=1.0.353"

  aws_account           = var.aws_account
  aws_region            = data.aws_region.current.name
  source_s3_bucket_name = aws_s3_bucket.file_transfer_bucket.id
}
