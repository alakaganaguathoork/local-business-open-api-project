locals {
  subnets = { subnet-1 = { subnet_cidr = var.subnet_cidr } }
  ecr_registry_url = module.ecr.repository_url
}