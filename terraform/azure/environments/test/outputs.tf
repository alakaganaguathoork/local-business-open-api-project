output "subnets" {
  value = module.app-kv.subnets
}

output "created_apps" {
  value     = module.app-kv.created_apps
  sensitive = true
}

output "subnets_address_prefixes" {
  value = module.app-kv.subnets_address_prefixes
}

output "private_endpoints" {
  value = module.app-kv.private_endpoints
}