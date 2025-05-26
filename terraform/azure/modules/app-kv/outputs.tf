#
### Key vault outputs
#
# output "kv_uri_infra" {
  # value = module.keyvault.kv_uri
# }
# 
# output "kv_private_endpoint_infra" {
  # value = module.keyvault.kv_private_endpoint
# }

output "subnets" {
  value = module.vnet.subnets
}