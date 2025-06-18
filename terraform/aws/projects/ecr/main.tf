module "networking" {
  source = "../../modules/networking"
  vpc_cidr_block = "10.0.0.0/16"
  subnets = local.subnets
  availability_zone = "eu-west-1b"
}

module "ecr" {
  source = "../../modules/ecr"

  region = var.region
  app_name = var.app_name
  build_context = var.build_context
  image_tag = var.image_tag
}

module "app_runner" {
  source = "../../modules/app-runner"

  region = var.region
  app_name = var.app_name
  image_identifier = module.ecr.image_identifier
  subnet_id = module.networking.subnets["subnet-1"].subnet.id
  security_group_id = [for value in values(module.networking.security_groups) : value.sg.id]
  repository_url = module.ecr.repository_url
}