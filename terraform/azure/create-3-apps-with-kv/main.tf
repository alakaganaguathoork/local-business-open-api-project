data "azurerm_client_config" "current" {

}

module "resource_group" {
  source = "../modules/resource-group"

  environment = var.environment
  location    = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.environment}-vnet"
  resource_group_name = module.resource_group.env.name
  location            = module.resource_group.env.location
  address_space       = var.networking_defaults.vnet_address_space
}

module "subnets" {
  source   = "../modules/networking/subnets"
  for_each = local.subnets

  environment          = var.environment
  resource_group_name  = module.resource_group.env.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  subnet               = each.value
}

module "keyvaults" {
  source   = "../modules/key-vault"
  for_each = local.keyvaults

  environment         = var.environment
  resource_group_name = module.resource_group.env.name
  location            = module.resource_group.env.location

  name       = each.value.name
  sku_name   = each.value.sku_name
  private_ip = each.value.private_ip
  my_ip      = var.networking_defaults.my_ip

  subnet_id = module.subnets["keyvault"].subnet.id
}

module "apps" {
  source   = "../modules/app-service"
  for_each = var.apps

  environment         = var.environment
  resource_group_name = module.resource_group.env.name
  location            = module.resource_group.env.location

  name         = each.key
  os_type      = each.value.os_type
  sku_name     = each.value.sku_name
  docker_image = each.value.docker_image

  subnet_id   = module.subnets[each.key].subnet.id
  keyvault_id = module.keyvaults[each.key].keyvault.id
}

module "keyvault_access_policies" {
  source   = "../modules/key-vault/access-policy"
  for_each = local.keyvaults

  keyvault_id                        = module.keyvaults[each.key].keyvault.id
  tenant_id                          = data.azurerm_client_config.current.tenant_id
  object_id                          = data.azurerm_client_config.current.object_id
  principal_id                       = module.apps[each.key].identity[0].principal_id
  general_keyvault_access_policies   = var.keyvault_access_policies.general
  principal_keyvault_access_policies = var.keyvault_access_policies.principal
}

module "keyvault_secrets" {
  source   = "../modules/key-vault/secrets"
  for_each = local.keyvaults

  keyvault_id = module.keyvaults[each.key].keyvault.id
  secrets     = each.value.secrets
  keys        = each.value.keys

  depends_on = [module.keyvault_access_policies]
}

# module "dns" {
# source = "../modules/networking/dns"
# environment = var.environment
# location = var.location
# private_dns_zone_name = "${var.environment}.mishap"
# vnet = module.vnet.vnet
# dns_a_records = module.keyvault.kv_private_endpoints
# }