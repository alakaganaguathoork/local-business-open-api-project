output "main_kv" {
  value = azurerm_key_vault.main_kv
}

output "kv_private_endpoints" {
  value = {
    for key, endpoint in azurerm_private_endpoint.private :
    key => {
      name = endpoint.ip_configuration[0].name
      private_ip_address = endpoint.ip_configuration[0].private_ip_address
    }
  }
}