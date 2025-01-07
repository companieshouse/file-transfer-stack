resource "aws_route53_record" "file_transfer_alb_r53_record" {
  count   = var.zone_id == "" ? 0 : 1 # zone_id defaults to empty string giving count = 0 i.e. not route 53 record

  zone_id         = var.zone_id
  name            = "file-transfer${var.internal_top_level_domain}"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = module.file_transfer_alb[0].application_load_balancer_dns_name
    zone_id                = module.file_transfer_alb[0].application_load_balancer_zone_id
    evaluate_target_health = false
  }

  depends_on = [ module.file_transfer_alb ]
}

resource "aws_route53_record" "secure_file_transfer_alb_r53_record" {
  count   = var.zone_id == "" ? 0 : 1 # zone_id defaults to empty string giving count = 0 i.e. not route 53 record

  zone_id         = var.zone_id
  name            = "secure-file-transfer${var.internal_top_level_domain}"

  type            = "A"
  allow_overwrite = true

  alias {
    name                   = module.secure_file_transfer_alb[0].application_load_balancer_dns_name
    zone_id                = module.secure_file_transfer_alb[0].application_load_balancer_zone_id
    evaluate_target_health = false
  }

  depends_on = [ module.secure_file_transfer_alb ]
}