output "app_names" {
  value = [
    for app in azurerm_linux_web_app.linux_app : app.name
  ]
}

output "resource_group_names" {
  value = [
    for rg in azurerm_resource_group.resource_group : rg.name
  ]
}