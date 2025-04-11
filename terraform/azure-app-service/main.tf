module "app_service" {
  source = "./modules/app-service-module"

  apps = local.instances
}
