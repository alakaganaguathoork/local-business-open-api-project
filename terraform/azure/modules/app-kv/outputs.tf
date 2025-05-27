output "subnets" {
  value = module.vnet.subnets
}

output "subnets_address_prefixes" {
  value = module.vnet.subnets_address_prefixes
}

output "kv_private_endpoints" {
  value = module.keyvault.kv_private_endpoints
}