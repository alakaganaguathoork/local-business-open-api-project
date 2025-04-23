output "linux_app_names" {
  value = module.app_service.linux_app_names
}

output "win_app_names" {
  value = module.app_service.win_app_names
}

output "resource_group_names" {
  value = module.app_service.resource_group_names
}
