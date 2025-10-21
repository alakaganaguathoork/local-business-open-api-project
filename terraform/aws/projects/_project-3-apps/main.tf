# module "networking" {
# source = "../../../aws/modules/networking"
# availability_zone = var.availability_zone
# vpc_cidr_block = var.vpc_cidr_block
# subnet_cidr_block = var.subnet_cidr_block
# }
# 
# resource "aws_instance" "app_server" {
# ami           = var.ami
# instance_type = var.instance_type
# subnet_id = module.networking.app_subnet_id
# }
