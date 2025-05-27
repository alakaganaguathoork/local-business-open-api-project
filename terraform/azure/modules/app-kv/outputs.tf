output "subnets" {
  value = module.vnet.subnets
}

output "created_apps" {
  value = module.apps.created_apps
}

output "subnets_address_prefixes" {
  value = module.vnet.subnets_address_prefixes
}

output "private_endpoints" {
  value = module.keyvault.private_endpoints
}