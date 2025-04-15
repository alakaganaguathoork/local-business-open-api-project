output "app_name" {
  value = {
    for idx, app in azurerm_linux_web_app.linux_app :
    idx => app.name
  }
}

output "resource_group_name" {
  value = {
    for idx, rg in azurerm_resource_group.resource_group :
    idx => rg.name
  }
}
