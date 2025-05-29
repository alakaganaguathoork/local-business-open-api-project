output "app" {
  value = coalesce(
    try(azurerm_linux_web_app.linux_app[0], null),
    try(azurerm_windows_web_app.win_app[0], null)
  )

  sensitive = true
}

output "app_id" {
  description = "ID of the created App Service (Linux or Windows)"
  value = coalesce(
    try(azurerm_linux_web_app.linux_app[0].id, null),
    try(azurerm_windows_web_app.win_app[0].id, null)
  )
}

output "identity" {
  description = "ID of the created App Service (Linux or Windows)"
  value = coalesce(
    try(azurerm_linux_web_app.linux_app[0].identity, null),
    try(azurerm_windows_web_app.win_app[0].identity, null)
  )

  sensitive = true
}
