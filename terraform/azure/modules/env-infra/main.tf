module "networking" {
  source      = "../../modules/networking"
  environment = var.environment
  location    = var.location
  subnets     = var.subnets
}

module "key_vault" {
  source      = "../../modules/key-vault"
  environment = var.environment
  location    = var.location
  keyvault    = var.keyvault
  subnet      = module.networking.subnets["keyvault"]
}

# module "app_service" {
#   depends_on = [module.networking]
#   source      = "../../modules/app-service"
#   environment = var.environment
#   location    = var.location
#   apps   = var.apps
#   subnets     = module.networking.subnets["app"]
# }