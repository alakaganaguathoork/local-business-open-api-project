output "subnet" {
  description = "Map of subnet names to their IDs"
  value = {
    id               = azurerm_subnet.subnet.id
    name             = azurerm_subnet.subnet.name
    address_prefixes = azurerm_subnet.subnet.address_prefixes
  }
}