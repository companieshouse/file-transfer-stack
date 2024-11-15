# ECS Service
variable "stack_name" {
  type        = string
  description = "The name of the Stack / ECS Cluster."
}
variable "name_prefix" {
  type        = string
  description = "The name prefix to be used for stack / environment name spacing."
}

# Environment
variable "environment" {
  type        = string
  description = "The environment name, defined in envrionments vars."
}

# Networking
variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs of application subnets from aws-mm-networks remote state."
}
variable "web_access_cidrs" {
  type        = list(string)
  description = "Subnet CIDRs for web ingress rules in the security group."
}
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC for the target group and security group."
}
variable "internal_albs" {
  type        = bool
  description = "Whether the ALBs should be internal or public facing"
}

# DNS
variable "zone_id" {
  type        = string
  description = "The ID of the hosted zone to contain the Route 53 record."
}
variable "external_top_level_domain" {
  type        = string
  description = "The type levelel of the DNS domain for external access."
}

# Certificates
variable "ssl_certificate_id" {
  type        = string
  description = "The ARN of the certificate for https access through the ALB."
}



variable "env" {}
variable "secure_file_transfer_create_alb" {
  description = "Override with value of 1 if this ALB is required in the environment"
  default = 1
}
variable "file_transfer_create_alb" {
  description = "Override with value 0 if this ELB is not required in the environment"
  default = 1
}
variable "service" {}
variable "secure_file_transfer_internet_facing" {
  default = 0
}
variable "routing_ids" {}
variable "secure_file_transfer_create_elb" {
  description = "Override with value 0 if this ELB is not required in the environment"
}
variable "gateway_ids_list" {
  description = "Contains a list of instance IDs for the deployment's gateway(s)"
  default     = []
}
variable "secure_data_app_create_alb" {
  description = "Override with value of 1 if this ALB is required in the environment"
}
variable "public_ids" {}
variable "alb_ssl_policy" {
  description = "The name of the SSL policy to use on ALB HTTPS listeners"
}
variable "secure_file_transfer_route53_target" {
  description = "Dictates whether the route53 record, if required, uses the \"elb\" or \"alb\" resources"
}
variable "create_route_53" {}
variable "zone_name" {}
variable "secure_data_app_internet_facing" {
  default = 0
}
variable "secure_data_app_create_elb" {
  description = "Override with value 0 if this ELB is not required in the environment"
  default = 1
}
variable "file_transfer_create_elb" {
  description = "Override with value 0 if this ELB is not required in the environment"
  default = 0
}
variable "filetransfer_route53_target" {
  description = "Dictates whether the route53 record, if required, uses the \"elb\" or \"alb\" resources"
}