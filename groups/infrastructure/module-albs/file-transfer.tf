# A security group for the ALB so it is accessible via the internal network
resource "aws_security_group" "file_transfer_alb" {
  count       = "${var.file_transfer_create_elb == 1 || var.file_transfer_create_alb == 1 ? 1 : 0}"
  vpc_id      = "${var.vpc_id}"

  # HTTP access from anywhere (on the internal network as this alb is hardcoded to internal = true)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSL access from anywhere (on the internal network as this alb is hardcoded to internal = true)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    environment = "${var.environment}"
    Name        = "${var.environment}-filetransfer"
  }

}
#------------------------------------------------------------------------------
# ALB Resources
#------------------------------------------------------------------------------
resource "aws_lb" "filetransfer_alb" {
  count = "${var.file_transfer_create_alb == 1 ? 1 : 0}"

  name               = "${var.environment}-filetransfer"
  subnets            = var.subnet_ids
  security_groups    = ["${aws_security_group.file_transfer_alb.id}"]
  internal           = true
  load_balancer_type = "application"
  idle_timeout       = 400

  tags {
    environment = "${var.environment}"
    Name        = "${var.environment}-filetransfer"
    ALB         = "true"
  }
}

resource "aws_lb_listener" "filetransfer_80" {
  count = "${var.file_transfer_create_alb == 1 ? 1 : 0}"

  load_balancer_arn = "${aws_lb.filetransfer_alb.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.filetransfer_18020.arn}"
  }
}

resource "aws_lb_listener" "filetransfer_443" {
  count = "${var.file_transfer_create_alb == 1 ? 1 : 0}"

  load_balancer_arn = "${aws_lb.filetransfer_alb.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "${var.ssl_certificate_id}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.filetransfer_18020.arn}"
  }
}

resource "aws_lb_target_group" "filetransfer_18020" {
  count = "${var.file_transfer_create_alb == 1 ? 1 : 0}"

  name     = "${var.environment}-filetransfer-18020"
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

resource "aws_lb_target_group_attachment" "filetransfer_18020" {
  count = "${var.file_transfer_create_alb == 1 ? length(var.gateway_ids_list) : 0}"

  target_group_arn = "${aws_lb_target_group.filetransfer_18020.arn}"
  target_id        = "${element(var.gateway_ids_list, count.index)}"
  port             = 18020
}

resource "aws_route53_record" "filetransfer_alb_r53_record" {
  count   = "${var.zone_id == "" ? 0 : 1}" # zone_id defaults to empty string giving count = 0 i.e. not route 53 record

  zone_id         = "${var.zone_id}"
  name            = "filetransfer${var.external_top_level_domain}"
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = "${aws_lb.filetransfer_alb.dns_name}"
    zone_id                = "${aws_lb.filetransfer_alb.zone_id}"
    evaluate_target_health = false
  }
}