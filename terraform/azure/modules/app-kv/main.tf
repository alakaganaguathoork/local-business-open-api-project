module "vnet" {
  source      = "../networking/vnet"
  environment = var.environment
  location    = var.location
  vpc_cidr    = var.vpc_cidr
  subnets     = local.subnets_to_create
}

module "ns_groups" {
  source      = "../networking/ns-groups"
  environment = var.environment
  location    = var.location
  nsg_rules   = local.nsg_rules
}

module "apps" {
  depends_on = [module.vnet]

  source      = "../app-service"
  environment = var.environment
  location    = var.location
  apps        = local.apps
  subnets     = module.vnet.subnets
}

module "keyvault" {
  depends_on = [module.vnet]

  source      = "../key-vault"
  environment = var.environment
  location    = var.location
  keyvaults   = local.keyvaults
  subnet      = module.vnet.subnets
}