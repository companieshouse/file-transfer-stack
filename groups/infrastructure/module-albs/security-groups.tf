resource "aws_security_group" "dev-site-sg" {
  description = "Security group for dev site albs"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.web_access_cidrs
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.web_access_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Name        = "${var.name_prefix}-alb-sg"
  }
}

resource "aws_security_group" "secure_file_transfer_alb" {
  count       = "${var.secure_file_transfer_create_alb == 1 || var.secure_file_transfer_create_elb == 1 ? 1 : 0}"
  vpc_id      = "${var.vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from anywhere
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
    environment = "${var.env}"
    service     = "${var.service}"
    Name        = "${var.env}-${var.service}-secure-filetransfer"
  }
}

# A security group for the ELB so it is accessible via the web
resource "aws_security_group" "secure_data_app_elb" {
  count       = "${var.secure_data_app_create_elb == 1 || var.secure_data_app_create_alb == 1 ? 1 : 0}"
  vpc_id      = "${var.vpc_id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access from anywhere
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
    environment = "${var.env}"
    service     = "${var.service}"
    Name        = "${var.env}-${var.service}-secure-data-app"
  }
}
