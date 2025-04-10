module "app_service" {
  source = "./modules/app_service_module"

  app_name = local.app_name
  apps     = local.instances
}
