output "integration_subnet_id" {
  value = one([
    for s in azurerm_subnet.subnets : 
      s.id if s.name == "integration"
  ])
}
