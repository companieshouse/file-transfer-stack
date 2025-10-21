# S3 anti-virus

A group that creates an s3 bucket, kms key for encryption and enables a guardduty malware protection plan against the bucket. Designed to be a replacement for the s3av solution in file-transfer-api.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3, < 2.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0, < 6.0 |
| <a name="requirement_vault"></a> [vault](#requirement\_vault) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0, < 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_malware_protection_plan.protection_plan](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_malware_protection_plan) | resource |
| [aws_iam_policy.guard_duty_malware_protection_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.guard_duty_malware_protection_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.guard_duty_malware_protection_policy_attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.file_transfer_encryption_key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.file_transfer_encryption_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket.file_transfer_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.file_transfer_bucket_ownership](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_public_access_block.file_transfer_bucket_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_versioning.file_transfer_bucket_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.guard_duty_malware_protection_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.guard_duty_malware_protection_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms_key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_file_transfer_bucket"></a> [file\_transfer\_bucket](#input\_file\_transfer\_bucket) | The name of the S3 bucket to create for user uploaded data. | `string` | n/a | yes |
| <a name="input_file_transfer_kms_alias"></a> [file\_transfer\_kms\_alias](#input\_file\_transfer\_kms\_alias) | The alias to assign to the KMS key used to encrypt user uploaded data. | `string` | n/a | yes |
| <a name="input_file_transfer_type"></a> [file\_transfer\_type](#input\_file\_transfer\_type) | The type of file transfer service to deploy | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
