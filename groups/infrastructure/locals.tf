locals {
  stack_name     = "file-transfer"
  stack_fullname = "${local.stack_name}-stack"
  name_prefix    = "${local.stack_name}-${var.environment}"

  stack_secrets = jsondecode(data.vault_generic_secret.secrets.data_json)

  application_subnet_pattern  = local.stack_secrets["application_subnet_pattern"]
  public_subnet_pattern       = local.stack_secrets["public_subnet_pattern"]
  application_subnet_ids      = join(",", data.aws_subnets.application.ids)
  kms_key_alias               = local.stack_secrets["kms_key_alias"]
  vpc_name                    = local.stack_secrets["vpc_name"]
  notify_topic_slack_endpoint = local.stack_secrets["notify_topic_slack_endpoint"]

  parameter_store_secrets = {
    "vpc-name"                 = local.stack_secrets["vpc_name"],
  }

  application_ids   = data.aws_subnets.application.ids
  application_cidrs = [for s in data.aws_subnet.application : s.cidr_block]

  lb_subnet_ids    = local.application_ids  # place ALB in correct subnets
  lb_access_cidrs  = concat(local.internal_cidrs,local.vpn_cidrs,local.management_private_subnet_cidrs,local.application_cidrs)

  internal_cidrs                  = values(data.terraform_remote_state.networks_common_infra.outputs.internal_cidrs)
  vpn_cidrs                       = values(data.terraform_remote_state.networks_common_infra.outputs.vpn_cidrs)
  management_private_subnet_cidrs = values(data.terraform_remote_state.networks_common_infra_ireland.outputs.management_private_subnet_cidrs)

}
