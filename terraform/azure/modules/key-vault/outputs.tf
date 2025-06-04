output "keyvault" {
  value = azurerm_key_vault.kv
}

output "private_ip_address" {
  value = azurerm_private_endpoint.private.ip_configuration[0].private_ip_address
}
