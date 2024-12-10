data "vault_generic_secret" "secrets" {
  path = "applications/${var.aws_profile}/${var.environment}/${local.stack_fullname}"
}

data "aws_kms_key" "stack_configs" {
  key_id = "alias/${var.aws_profile}/${local.kms_key_alias}"
}

data "aws_subnets" "application" {
  filter {
    name   = "tag:Name"
    values = [local.application_subnet_pattern]
  }
  filter {
    name   = "tag:NetworkType"
    values = ["private"]
  }
}

data "aws_subnet" "application" {
  for_each = toset(data.aws_subnets.application.ids)
  id       = each.value
}

data "aws_vpc" "vpc" {
  filter {
    name   = "tag:Name"
    values = [local.vpc_name]
  }
}

data "aws_acm_certificate" "cert" {
  domain = var.cert_domain
}

data "aws_subnet" "routing_subnets" {
  count  = length(local.stack_secrets["routing_subnet_pattern"])
  vpc_id = data.aws_vpc.vpc.id
  filter {
    name   = "tag:Name"
    values = [local.stack_secrets["routing_subnet_pattern"][count.index]]
  }
}
