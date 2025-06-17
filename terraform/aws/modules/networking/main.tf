resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

module "subnet" {
  for_each = var.subnets
  source   = "./subnet"

  subnet_cidr       = each.value.subnet_cidr
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone
}

locals {
  security_groups = {
    allow_tls = {
      name        = "Allow TLS"
      description = "Allow secure connections in subnets"
      ingress_rule = {
        for key, value in var.subnets :
        key => {
          cidr_ipv4   = value.subnet_cidr
          from_port   = 443
          ip_protocol = "tcp"
          to_port     = 443
        }
      }
      egress_rule = {
        allow_all = {
          cidr_ipv4   = "0.0.0.0/0"
          ip_protocol = "-1" # semantically equivalent to all ports 
        }
      }
    }
  }
}

# Security Groups
module "security_group" {
  for_each = local.security_groups
  source   = "./security-group"

  name         = each.value.name
  description  = each.value.description
  vpc_id       = aws_vpc.main.id
  ingress_rule = each.value.ingress_rule
  egress_rule  = each.value.egress_rule
}
