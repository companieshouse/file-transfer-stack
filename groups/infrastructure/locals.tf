locals {
  stack_name     = "file-transfer"
  stack_fullname = "${local.stack_name}-stack"
  name_prefix    = "${local.stack_name}-${var.environment}"

  stack_secrets = jsondecode(data.vault_generic_secret.secrets.data_json)

  application_subnet_pattern  = local.stack_secrets["application_subnet_pattern"]
  application_subnet_ids      = join(",", data.aws_subnets.application.ids)
  kms_key_alias               = local.stack_secrets["kms_key_alias"]
  vpc_name                    = local.stack_secrets["vpc_name"]
  notify_topic_slack_endpoint = local.stack_secrets["notify_topic_slack_endpoint"]

  routing_subnet_ids = zipmap(
    data.aws_subnet.routing_subnets.*.availability_zone,
    data.aws_subnet.routing_subnets.*.id
  )

}
