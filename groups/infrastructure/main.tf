provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {}
  required_version = "~> 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.54.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.18.0"
    }
  }
}

module "ecs-cluster" {
  source = "git@github.com:companieshouse/terraform-modules//aws/ecs/ecs-cluster?ref=1.0.296"

  stack_name                  = local.stack_name
  name_prefix                 = local.name_prefix
  environment                 = var.environment
  aws_profile                 = var.aws_profile
  vpc_id                      = data.aws_vpc.vpc.id
  subnet_ids                  = local.application_subnet_ids
  ec2_key_pair_name           = var.ec2_key_pair_name
  ec2_instance_type           = var.ec2_instance_type
  ec2_image_id                = var.ec2_image_id
  asg_max_instance_count      = var.asg_max_instance_count
  asg_min_instance_count      = var.asg_min_instance_count
  enable_container_insights   = var.enable_container_insights
  asg_desired_instance_count  = var.asg_desired_instance_count
  scaledown_schedule          = var.asg_scaledown_schedule
  scaleup_schedule            = var.asg_scaleup_schedule
  enable_asg_autoscaling      = var.enable_asg_autoscaling
  notify_topic_slack_endpoint = local.notify_topic_slack_endpoint
}

module "secrets" {
  source = "git@github.com:companieshouse/terraform-modules//aws/ecs/secrets?ref=1.0.296"

  environment = var.environment
  name_prefix = local.name_prefix
  secrets     = local.parameter_store_secrets
  kms_key_id  = data.aws_kms_key.stack_configs.id
}

module "file_transfer_alb" {
  count = "${var.file_transfer_create_alb == 1 ? 1 : 0}"


  source = "git@github.com:companieshouse/terraform-modules//aws/application_load_balancer?ref=1.0.296"
  environment         = var.environment
  service             = "file-transfer"
  ssl_certificate_arn = data.aws_acm_certificate.cert.arn
  subnet_ids          = values(local.routing_subnet_ids)
  vpc_id              = data.aws_vpc.vpc.id
  idle_timeout        = 1200
  route53_domain_name     = var.cert_domain
  create_security_group  = true
  internal               = true
  ingress_cidrs          = ["0.0.0.0/0"]
  redirect_http_to_https = true
  service_configuration  = {
    default = {
      listener_config = {
        default_action_type = "fixed-response"
        port                = 443
      }
    }
  }
}

  module "secure_file_transfer_alb" {
    count = "${var.secure_file_transfer_create_alb == 1 ? 1 : 0}"
    source = "git@github.com:companieshouse/terraform-modules//aws/application_load_balancer?ref=1.0.296"
    environment         = var.environment
    service             = "secure-file-transfer"
    ssl_certificate_arn = data.aws_acm_certificate.cert.arn
    subnet_ids          = values(local.routing_subnet_ids)
    vpc_id              = data.aws_vpc.vpc.id
    idle_timeout        = 1200
    route53_domain_name = var.cert_domain
    create_security_group  = true
    internal               = true
    ingress_cidrs          = ["0.0.0.0/0"]
    redirect_http_to_https = true
    service_configuration  = {
      default = {
        listener_config = {
          default_action_type = "fixed-response"
          content_type = "text/plain"
          message_body = "OK"
          status_code  = "404"
        }
      }
    }
  }