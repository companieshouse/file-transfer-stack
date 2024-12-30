terraform {
  required_version = ">= 1.3, < 2.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
}

terraform {
  backend "s3" {}
}

module "file_transfer_alb" {
  source                    = "git@github.com:companieshouse/terraform-modules//aws/application_load_balancer?ref=1.0.231"
  count                     = var.file_transfer_create_alb ? 1 : 0

  environment               = var.environment
  service                   = "file-transfer"
  ssl_certificate_arn       = data.aws_acm_certificate.cert.arn
  subnet_ids                = values(local.routing_subnet_ids)
  vpc_id                    = data.aws_vpc.vpc.id
  route53_domain_name       = var.cert_domain

  create_security_group     = true
  internal                  = true
  ingress_cidrs             = local.ingress_cidrs_private
  ingress_prefix_list_ids   = local.ingress_prefix_list_ids
  service_configuration = {
    default = {
      listener_config = {
        default_action_type = "fixed-response"
        port                = 443
        fixed_response = {
          message_body = "unauthorized"
          status_code  = 401
        }
      }
    }
  }
}

module "secure_file_transfer_alb" {
  source                  = "git@github.com:companieshouse/terraform-modules//aws/application_load_balancer?ref=1.0.296"
  count                   = var.secure_file_transfer_create_alb ? 1 : 0

  environment             = var.environment
  service                 = "secure-file-transfer"
  ssl_certificate_arn     = data.aws_acm_certificate.cert.arn
  subnet_ids              = values(local.routing_subnet_ids)
  vpc_id                  = data.aws_vpc.vpc.id
  route53_domain_name     = var.cert_domain

  create_security_group   = true
  internal                = true
  ingress_cidrs           = local.ingress_cidrs_private
  ingress_prefix_list_ids = local.ingress_prefix_list_ids
  service_configuration   = {
    listener_config       = {
      default_action_type = "fixed-response"
      protocol            = "HTTPS"
      port                = 443
      fixed_response      = {
        content_type      = "text/plain"
        message_body      = "OK"
        status_code       = "404"
      }
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
  asg_max_instance_count      = var.asg_max_instance_count
  asg_min_instance_count      = var.asg_min_instance_count
  enable_container_insights   = var.enable_container_insights
  asg_desired_instance_count  = var.asg_desired_instance_count
  scaledown_schedule          = var.asg_scaledown_schedule
  scaleup_schedule            = var.asg_scaleup_schedule
  enable_asg_autoscaling      = var.enable_asg_autoscaling
  notify_topic_slack_endpoint = local.notify_topic_slack_endpoint
}

