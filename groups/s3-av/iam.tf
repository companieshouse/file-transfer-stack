resource "aws_iam_role" "guard_duty_malware_protection_role" {
  assume_role_policy    = data.aws_iam_policy_document.guard_duty_malware_protection_assume_role_policy.json
  description           = "Role for Guard Duty Malware Protection for ${var.file_transfer_type}"
  force_detach_policies = false
  max_session_duration  = 3600
  name                  = "${var.file_transfer_type}-guard-duty-malware-protection-iam-role"
  path                  = "/"
  tags                  = local.tags
}

resource "aws_iam_policy" "guard_duty_malware_protection_policy" {
  name        = "guard-duty-malware-protection-policy"
  description = "Allows Guard Duty to access Event Bridge and S3"
  policy      = data.aws_iam_policy_document.guard_duty_malware_protection_policy.json
}

resource "aws_iam_role_policy_attachment" "guard_duty_malware_protection_policy_attachment" {
  role       = aws_iam_role.guard_duty_malware_protection_role.name
  policy_arn = aws_iam_policy.guard_duty_malware_protection_policy.arn
}
