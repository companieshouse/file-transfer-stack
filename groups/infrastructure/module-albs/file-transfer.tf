
#------------------------------------------------------------------------------
# ALB Resources
#------------------------------------------------------------------------------
resource "aws_lb" "file_transfer_alb" {
  count = "${var.file_transfer_create_alb == 1 ? 1 : 0}"

  name               = "${var.environment}-file-transfer"
  subnets            = var.subnet_ids
  security_groups    = ["${aws_security_group.file-transfer-sg.id}"]
  internal           = true
  load_balancer_type = "application"
  idle_timeout       = 400

  tags = {
    Environment = "${var.environment}"
    Name        = "${var.environment}-file-transfer"
    ALB         = "true"
  }
}

resource "aws_lb_listener" "file_transfer_80" {
  count = "${var.file_transfer_create_alb == 1 ? 1 : 0}"

  load_balancer_arn = "${aws_lb.file_transfer_alb[0].arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.file_transfer_18020[0].arn}"
  }
}

resource "aws_lb_listener" "file_transfer_443" {
  count = "${var.file_transfer_create_alb == 1 ? 1 : 0}"

  load_balancer_arn = "${aws_lb.file_transfer_alb[0].arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.ssl_certificate_id}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.file_transfer_18020[0].arn}"
  }
}

resource "aws_lb_target_group" "file_transfer_18020" {
  count = "${var.file_transfer_create_alb == 1 ? 1 : 0}"

  name     = "${var.environment}-file-transfer-18020"
  port     = 18020
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/haproxy_healthcheck"
    port                = "10003"
    protocol            = "HTTP"
    timeout             = "3"
  }
}

resource "aws_lb_target_group_attachment" "file_transfer_18020" {
  count = "${var.file_transfer_create_alb == 1 ? length(var.gateway_ids_list) : 0}"
  target_group_arn = "${aws_lb_target_group.file_transfer_18020[0].arn}"
  target_id        = "${element(var.gateway_ids_list, 0)}"
  port             = 18020
}

resource "aws_route53_record" "file_transfer_alb_r53_record" {
  count   = "${var.zone_id == "" ? 0 : 1}" # zone_id defaults to empty string giving count = 0 i.e. not route 53 record

  zone_id         = "${var.zone_id}"
  name            = "file-transfer${var.external_top_level_domain}"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = "${aws_lb.file_transfer_alb[0].dns_name}"
    zone_id                = "${aws_lb.file_transfer_alb[0].zone_id}"
    evaluate_target_health = false
  }
}