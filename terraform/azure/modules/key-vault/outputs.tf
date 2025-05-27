output "main_kv" {
  value = azurerm_key_vault.main_kv
}

output "private_endpoints" {
  value = {
    for key, endpoint in azurerm_private_endpoint.private :
    key => endpoint.ip_configuration[0].private_ip_address
  }
}