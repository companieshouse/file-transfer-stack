data "vault_generic_secret" "secrets" {
  path = local.vault_path
}

data "aws_subnets" "application" {
  filter {
    name   = "tag:Name"
    values = [local.application_subnet_pattern]
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

data "aws_ec2_managed_prefix_list" "admin" {
  name = "administration-cidr-ranges"
}

data "aws_ec2_managed_prefix_list" "shared_services_management" {
  name = "shared-services-management-cidrs"
}

data "aws_route53_zone" "zone" {
  count = (var.secure_file_transfer_create_alb || var.file_transfer_create_alb) && trimspace(local.zone_name) != "" ? 1 : 0

  name         = local.zone_name
  private_zone = var.private_zone
}
