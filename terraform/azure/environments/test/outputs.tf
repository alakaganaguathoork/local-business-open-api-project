output "app_names" {
  value = module.app_service.app_names
}

output "resource_group_names" {
  value = module.app_service.resource_group_names
}

output "subnets" {
  value = module.networking.subnets
}