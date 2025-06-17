# Networking
module "vpc" {
  source = "../../modules/networking"

  availability_zone = var.availability_zone
  vpc_cidr_block    = var.vpc_cidr_block
  subnets           = local.subnets
}

resource "aws_route_table" "rt" {
  for_each = var.apps
  vpc_id   = module.vpc.vpc_id
}

resource "aws_route_table_association" "a" {
  for_each = var.apps

  subnet_id      = module.vpc.subnets[each.key].subnet.id
  route_table_id = aws_route_table.rt[each.key].id
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

resource "aws_instance" "main" {
  for_each = var.apps

  ami                    = data.aws_ami.amazon_linux2.id
  instance_type          = var.instance_type
  subnet_id              = module.vpc.subnets[each.key].subnet.id
  vpc_security_group_ids = [for value in values(module.vpc.security_groups) : value.sg.id]
}