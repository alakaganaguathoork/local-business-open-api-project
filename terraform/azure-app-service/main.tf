module "app_service" {
  source = "./modules/app_service_module"

  apps = local.instances
}
