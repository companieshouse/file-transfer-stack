resource "aws_route53_record" "file_transfer_alb_r53_record" {
  count = var.file_transfer_create_alb && trimspace(local.zone_name) != "" ? 1 : 0

  zone_id         = data.aws_route53_zone.zone[0].zone_id
  name            = "file-transfer.${var.environment}.${local.zone_name}"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = module.file_transfer_alb[0].application_load_balancer_dns_name
    zone_id                = module.file_transfer_alb[0].application_load_balancer_zone_id
    evaluate_target_health = false
  }

  depends_on = [module.file_transfer_alb]
}

resource "aws_route53_record" "secure_file_transfer_alb_r53_record" {
  count = var.secure_file_transfer_create_alb && trimspace(local.zone_name) != "" ? 1 : 0

  zone_id = data.aws_route53_zone.zone[0].zone_id
  name    = "secure-file-transfer.${var.environment}.${local.zone_name}"

  type            = "A"
  allow_overwrite = true

  alias {
    name                   = module.secure_file_transfer_alb[0].application_load_balancer_dns_name
    zone_id                = module.secure_file_transfer_alb[0].application_load_balancer_zone_id
    evaluate_target_health = false
  }

  depends_on = [module.secure_file_transfer_alb]
}
