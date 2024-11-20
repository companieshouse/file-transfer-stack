resource "aws_lb" "secure_file_transfer_alb" {
  count = "${var.secure_file_transfer_create_alb == 1 ? 1 : 0}"

  name               = "${var.environment}-secure-filetransfer"
  subnets            = var.subnet_ids
  security_groups    = ["${aws_security_group.secure-file-transfer_sg.id}"]
  internal           = "${var.secure_file_transfer_internet_facing == 0 ? true : false}"
  load_balancer_type = "application"
  idle_timeout       = 400

  tags {
    environment = "${var.environment}"
    Name        = "${var.environment}-secure-filetransfer"
    ALB         = "true"
  }
}

resource "aws_lb_listener" "secure_file_transfer_80" {
  count = "${var.secure_file_transfer_create_alb == 1 ? 1 : 0}"

  load_balancer_arn = "${aws_lb.secure_file_transfer_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.secure_file_transfer_8080.arn}"
  }
}

resource "aws_lb_listener" "secure_file_transfer_443" {
  count = "${var.secure_file_transfer_create_alb == 1 ? 1 : 0}"

  load_balancer_arn = "${aws_lb.secure_file_transfer_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.ssl_certificate_id}"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "OK"
      status_code  = "404"
    }
  }
}
resource "aws_lb_target_group" "secure_file_transfer_8080" {
  count = "${var.secure_file_transfer_create_alb == 1 ? 1 : 0}"

  name     = "${var.environment}-secure-file-transfer-8080"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/haproxy_healthcheck"
    port                = "9090"
    protocol            = "HTTP"
    timeout             = "3"
  }
}

resource "aws_lb_target_group_attachment" "secure_file_transfer_8080" {
  count = "${var.secure_file_transfer_create_alb == 1 ? length(var.gateway_ids_list) : 0}"

  target_group_arn = "${aws_lb_target_group.secure_file_transfer_8080.arn}"
  target_id        = "${element(var.gateway_ids_list, count.index)}"
  port             = 8080
}


resource "aws_lb_target_group" "secure_file_transfer_18538" {
  count = "${var.secure_file_transfer_create_alb == 1 ? 1 : 0}"

  name     = "${var.environment}-secure-file-transfer-18538"
  port     = 18538
  protocol = "HTTP"
  vpc_id   = "${var.vpc_id}"

  health_check {
    healthy_threshold   = "2"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/haproxy_healthcheck"
    port                = "9090"
    protocol            = "HTTP"
    timeout             = "3"
  }
}

resource "aws_lb_target_group_attachment" "secure_file_transfer_18538" {
  count = "${var.secure_file_transfer_create_alb == 1 ? length(var.gateway_ids_list) : 0}"

  target_group_arn = "${aws_lb_target_group.secure_file_transfer_18538.arn}"
  target_id        = "${element(var.gateway_ids_list, count.index)}"
  port             = 18538
}

resource "aws_route53_record" "secure_file_transfer_alb_r53_record" {
  count   = "${var.zone_id == "" ? 0 : 1}" # zone_id defaults to empty string giving count = 0 i.e. not route 53 record

  zone_id         = "${var.zone_id}"
  name            = "secure-file-transfer${var.external_top_level_domain}"

  type            = "A"
  allow_overwrite = true

  alias {
    name                   = "${aws_lb.secure_file_transfer_alb.dns_name}"
    zone_id                = "${aws_lb.secure_file_transfer_alb.zone_id}"
    evaluate_target_health = false
  }
}
