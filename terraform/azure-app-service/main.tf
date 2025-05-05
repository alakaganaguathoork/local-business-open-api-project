module "vnet" {
  source   = "./modules/networking/vnet"
  location = local.location
  subnets  = local.subnets
}

module "app_service" {
  source     = "./modules/app-service-module"
  apps       = local.instance
  depends_on = [module.vnet]
}

# module "key_vault" {
# source   = "./modules/key-vault"
# location = local.location
# }