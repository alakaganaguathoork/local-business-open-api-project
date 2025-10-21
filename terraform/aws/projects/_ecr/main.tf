module "networking" {
  source = "../../modules/networking"

  vpc_cidr_block = var.vpc_cidr_block
  public_subnets = local.subnets
  enable_gateway = true
  enable_nat = false
}

module "security_group" {
  source = "../../modules/networking/security-group"
  vpc_id = module.networking.vpc_id
  security_groups = local.security_groups
}

module "ecr" {
  source = "../../modules/ecr"
  providers = {
    docker = docker.main
  }
  for_each = var.apps

  region = var.region
  app_name = each.value.name
  build_context = var.build_context
  image_tag = each.value.image_tag
}

module "app_runner" {
  source = "../../modules/app-runner"
  for_each = var.apps

  region = var.region
  app_name = each.value.name
  image_identifier = module.ecr[each.key].image_identifier
  subnet_id = module.networking.public_subnets[each.key].id
  security_group_id = [for value in values(module.security_groups) : value.sg.id]
  repository_url = module.ecr[each.key].repository_url

  depends_on = [ module.networking.ingress_rule ]
}