module "networking" {
  source      = "../../modules/networking"
  environment = var.environment
  location    = var.location
  subnets   = var.subnets
}
# 
# module "app_service" {
#   source      = "../../modules/app-service"
#   environment = var.environment
#   location    = var.location
#   instances   = var.instances
#   subnets     = module.networking.subnets
# 
#   depends_on = [module.networking]
# }

module "key_vault" {
  source = "../../modules/key-vault"
  environment = var.environment
  location = var.location
}