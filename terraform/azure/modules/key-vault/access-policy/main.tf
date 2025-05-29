resource "azurerm_key_vault_access_policy" "general" {
  key_vault_id = var.keyvault_id
  tenant_id    = var.tenant_id
  object_id    = var.object_id

  secret_permissions  = var.general_keyvault_access_policies.secret_permissions
  key_permissions     = var.general_keyvault_access_policies.key_permissions
  storage_permissions = var.general_keyvault_access_policies.storage_permissions
}

resource "azurerm_key_vault_access_policy" "principal" {
  key_vault_id = var.keyvault_id
  tenant_id    = var.tenant_id
  object_id    = var.principal_id

  secret_permissions  = var.principal_keyvault_access_policies.secret_permissions
  key_permissions     = var.principal_keyvault_access_policies.key_permissions
  storage_permissions = var.principal_keyvault_access_policies.storage_permissions
}