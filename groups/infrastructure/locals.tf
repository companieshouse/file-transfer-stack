locals {
  stack_name     = "file-transfer"
  stack_fullname = "${local.stack_name}-stack"
  name_prefix    = "${local.stack_name}-${var.environment}"
  vault_path     = "${var.protect_regime ? "secure-" : ""}applications/${var.aws_profile}/${var.environment}/${local.stack_fullname}"

  stack_secrets = jsondecode(data.vault_generic_secret.secrets.data_json)
  zone_name     = lookup(local.stack_secrets, "zone_name", "")

  application_subnet_pattern  = local.stack_secrets["application_subnet_pattern"]
  application_subnet_ids      = join(",", data.aws_subnets.application.ids)
  vpc_name                    = local.stack_secrets["vpc_name"]
  notify_topic_slack_endpoint = local.stack_secrets["notify_topic_slack_endpoint"]

  routing_subnet_ids = zipmap(
    data.aws_subnet.routing_subnets.*.availability_zone,
    data.aws_subnet.routing_subnets.*.id
  )

  ingress_cidrs_private   = [for subnet in data.aws_subnet.application : subnet.cidr_block]
  ingress_prefix_list_ids = var.protect_regime ? [] : [data.aws_ec2_managed_prefix_list.admin.id, data.aws_ec2_managed_prefix_list.shared_services_management.id]
}
