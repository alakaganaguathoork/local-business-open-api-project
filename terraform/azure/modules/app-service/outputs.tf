output "linux_apps" {
  value = azurerm_linux_web_app.linux_app
}

output "resource_group" {
  value = azurerm_resource_group.instances
}