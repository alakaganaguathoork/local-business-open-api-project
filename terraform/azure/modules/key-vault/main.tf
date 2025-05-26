data "azurerm_client_config" "current" {

}

resource "random_string" "random" {
  for_each = var.keyvaults

  length  = 7
  numeric = true
  special = false
}

resource "azurerm_resource_group" "kv" {
  name     = "${var.environment}-keyvaultsRG"
  location = var.location
}

resource "azurerm_user_assigned_identity" "iam" {
  name                = "iam-admin-${var.environment}"
  location            = azurerm_resource_group.kv.location
  resource_group_name = azurerm_resource_group.kv.name
}

resource "azurerm_key_vault" "main_kv" {
  depends_on = [ data.azurerm_client_config.current ]

  for_each = var.keyvaults
  
  name                        = "${each.value.name}-${var.environment}-${random_string.random[each.key].result}-kv"
  location                    = azurerm_resource_group.kv.location
  resource_group_name         = azurerm_resource_group.kv.name
  enabled_for_disk_encryption = true
  tenant_id                   = azurerm_user_assigned_identity.iam.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  sku_name = lower(each.value.sku_name)
  
  # dynamic "access_policy" {
    # for_each = local.keyvault_access_policies
    # content {
      # tenant_id       = access_policy.value.tenant_id
      # object_id       = access_policy.value.object_id
      # key_permissions = access_policy.value.key_permissions
    # }
  # }

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = ["Get", "List", "Create", "Delete", "Update", "Recover", "Purge", "GetRotationPolicy"]
  }

  access_policy {
    tenant_id = azurerm_user_assigned_identity.iam.tenant_id
    object_id = azurerm_user_assigned_identity.iam.principal_id

    key_permissions = ["Get", "WrapKey", "UnwrapKey"]
  }
}

resource "azurerm_private_endpoint" "private" {
  depends_on = [azurerm_key_vault.main_kv]

  for_each = var.keyvaults

  name                = "${azurerm_key_vault.main_kv[each.key].name}-endpoint"
  location            = var.location
  resource_group_name = var.subnet["keyvault"].resource_group_name
  subnet_id           = var.subnet["keyvault"].id

  ip_configuration {
    name = "${each.value.name}-ip"
    private_ip_address = each.value.kv_ip
    subresource_name = "vault"
    member_name         = "default"
  }
  private_service_connection {
    name                           = "${azurerm_key_vault.main_kv[each.key].name}-privateserviceconnection"
    private_connection_resource_id = azurerm_key_vault.main_kv[each.key].id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

resource "azurerm_key_vault_key" "mysql" {
  depends_on = [ azurerm_key_vault.main_kv ]

  for_each = azurerm_key_vault.main_kv

  name         = "mysql-key-${var.environment}"
  key_vault_id = each.value.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = ["unwrapKey", "wrapKey"]
}