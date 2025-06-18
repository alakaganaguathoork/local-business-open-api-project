# Networking
module "vpc" {
  source = "../../modules/networking"

  availability_zone = var.availability_zone
  vpc_cidr_block    = var.vpc_cidr_block
  subnets           = local.subnets
}

# Instance
data "aws_ami" "amazon_linux2" {
  # Always return the single most recent matching image
  most_recent = true

  # Owner “amazon” publishes official Amazon Linux 2 AMIs
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# resource "aws_instance" "main" {
  # for_each = var.apps
# 
  # ami                    = data.aws_ami.amazon_linux2.id
  # instance_type          = var.instance_type
  # subnet_id              = module.vpc.subnets[each.key].subnet.id
  # vpc_security_group_ids = [for value in values(module.vpc.security_groups) : value.sg.id]
# }


# module "app_runner" {
  # for_each = var.apps
# 
  # source = "../../modules/app-runner"
# 
  # subnet_id = module.vpc.subnets[each.key].subnet.id
  # security_group_id = [for value in values(module.vpc.security_groups) : value.sg.id]
# }