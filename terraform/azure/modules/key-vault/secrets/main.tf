resource "azurerm_key_vault_key" "key" {
  for_each = {
    for key in var.keys :
    key.name => key
  }

  key_vault_id = var.keyvault_id
  name         = each.key
  key_type     = each.value.key_type
  key_opts     = each.value.key_opts
  key_size     = each.value.key_size
}

resource "azurerm_key_vault_secret" "secret" {
  for_each = {
    for secret in var.secrets :
    secret.name => secret
  }

  key_vault_id = var.keyvault_id
  name         = each.key
  content_type = each.value.content_type
  value        = each.value.value
}