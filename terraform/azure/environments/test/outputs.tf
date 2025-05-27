# output "subnets" {
  # value = module.app-kv.subnets
# }

output "subnets_address_prefixes" {
  value = module.app-kv.subnets_address_prefixes
}

output "keyvaults_private_endpoints" {
  value = module.app-kv.kv_private_endpoints
}