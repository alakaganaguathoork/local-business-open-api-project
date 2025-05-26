module "vnet" {
  source      = "../../modules/networking/vnet"
  environment = var.environment
  location    = var.location
  subnets     = local.subnets_to_create
}

module "apps" {
  depends_on = [ module.vnet ]

  source = "../app-service"
  environment = var.environment
  location = var.location
  apps = local.apps
  subnets = module.vnet.subnets
}

module "keyvault" {
  depends_on = [ module.vnet ]

  source = "../key-vault"
  environment = var.environment
  location = var.location
  keyvaults = local.keyvaults
  subnet = module.vnet.subnets
}