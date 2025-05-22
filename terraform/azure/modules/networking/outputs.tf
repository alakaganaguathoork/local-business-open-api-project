output "subnets" {
  value = azurerm_subnet.subnet
}

output "subnet_keyvault" {
  value = azurerm_subnet.subnet["keyvault"]
}

output "app_subnets" {
  value = {
    for key, subnet in azurerm_subnet.subnet : key => subnet if subnet.name == "subnet-app-${var.environment}"
  }
}

output "intergration_subnets" {
  value = {
    for key, subnet in azurerm_subnet.subnet : key => subnet.id if subnet.name != "subnet-app-${var.environment}"
  }
}

output "resource_group" {
  value = azurerm_resource_group.networking
}