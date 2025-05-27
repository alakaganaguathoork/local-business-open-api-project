# locals {
# object_keyvault_access_policy = {
# for key, value in var.keyvaults.access_policies : 
# key => {
# tenant_id = data.azurerm_client_config.current.tenant_id
# object_id = data.azurerm_client_config.current.object_id
# key_permissions = value.key_permissions
# }
# if key == "object"
#  }
# }
# 
# locals {
# principal_keyvault_access_policy = {
# for key, value in var.keyvaults.access_policies :
# key => {
# tenant_id = azurerm_user_assigned_identity.iam.tenant_id
# object_id = azurerm_user_assigned_identity.iam.principal_id
# key_permissions = value.key_permissions
# }
# if key == "principal"
# }
# }
# 
# locals {
# keyvault_access_policies = concat(
# values(local.object_keyvault_access_policy),
# values(local.principal_keyvault_access_policy)
# )
# }