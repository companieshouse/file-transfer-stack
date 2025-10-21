data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "guard_duty_malware_protection_assume_role_policy" {
  statement {
    sid    = "GuardDutyMalwareProtectionForS3"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["malware-protection-plan.guardduty.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:guardduty:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:malware-protection-plan/*"]
    }
  }
}

data "aws_iam_policy_document" "guard_duty_malware_protection_policy" {
  statement {
    sid    = "AllowEventsGuardDuty"
    effect = "Allow"

    actions = [
      "events:PutRule",
      "events:DescribeRule",
      "events:ListTargetsByRule",
      "events:DeleteRule",
      "events:PutTargets",
      "events:RemoveTargets"
    ]

    resources = [
      "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/DO-NOT-DELETE-AmazonGuardDutyMalwareProtectionS3*"
    ]

    condition {
      test     = "StringEquals"
      variable = "events:ManagedBy"
      values   = ["malware-protection-plan.guardduty.amazonaws.com"]
    }

    condition {
      test     = "ForAllValues:StringEquals"
      variable = "events:source"
      values   = ["aws.s3"]
    }
  }

  statement {
    sid    = "AllowS3GuardDuty"
    effect = "Allow"

    actions = [
      "s3:PutBucketNotification",
      "s3:GetBucketNotification",
      "s3:GetObjectTagging",
      "s3:GetObjectVersionTagging",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionTagging",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]
    resources = [
      aws_s3_bucket.file_transfer_bucket.arn,
      "${aws_s3_bucket.file_transfer_bucket.arn}/*"
    ]
  }

  statement {
    sid    = "AllowKMSGuardDuty"
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
      "kms:DescribeKey"
    ]
    resources = [
      aws_kms_key.file_transfer_encryption_key.arn
    ]
  }
}

data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid = "AllowAccountAdministrators"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowGuardDutyRoleUsage"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/guardduty.amazonaws.com/AWSServiceRoleForAmazonGuardDuty"]
    }
  }
}
