variable "file_transfer_bucket" {
  type        = string
  description = "The name of the S3 bucket to create for user uploaded data."
}

variable "file_transfer_kms_alias" {
  type        = string
  description = "The alias to assign to the KMS key used to encrypt user uploaded data."
}

variable "file_transfer_type" {
  type        = string
  description = "The type of file transfer service to deploy"
}
