data "azurerm_client_config" "current" {

}

module "resource_group" {
  source = "../../modules/resource-group"

  environment = local.environment
  location    = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${local.environment}-vnet"
  resource_group_name = module.resource_group.env.name
  location            = module.resource_group.env.location
  address_space       = var.networking_defaults.vnet_address_space
}

module "subnets" {
  source   = "../../modules/networking/subnets"
  for_each = local.subnets

  environment          = local.environment
  resource_group_name  = module.resource_group.env.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  subnet               = each.value
}

module "dns_zones" {
  source = "../../modules/networking/dns"
  for_each = local.dns_zones

  environment = local.environment
  location = module.resource_group.env.location
  resource_group_name = module.resource_group.env.name
  vnet_id = azurerm_virtual_network.vnet.id
  zone_name = each.value
}

module "keyvaults" {
  source   = "../../modules/key-vault"
  for_each = local.keyvaults

  environment         = local.environment
  company             = var.company
  resource_group_name = module.resource_group.env.name
  location            = module.resource_group.env.location

  name       = each.value.name
  sku_name   = each.value.sku_name
  private_ip = each.value.private_ip
  my_ip      = var.networking_defaults.my_ip

  subnet_id              = module.subnets["keyvault"].subnet.id
  keyvault_dns_zone_name = module.dns_zones["keyvault"].dns_zone.name
}

module "storage_account" {
  source = "../../modules/storage-account"

  environment         = local.environment
  resource_group_name = module.resource_group.env.name
  location            = module.resource_group.env.location

  vnet_id = azurerm_virtual_network.vnet.id
  subnet_id = module.subnets["storage"].subnet.id
  storage_dns_zone_name = module.dns_zones["storage"].dns_zone.name
}

module "apps" {
  source   = "../../modules/app-service"
  for_each = local.apps

  environment         = local.environment
  resource_group_name = module.resource_group.env.name
  location            = module.resource_group.env.location

  name         = each.key
  os_type      = each.value.os_type
  sku_name     = each.value.sku_name
  docker_image = each.value.docker_image

  subnet_id       = module.subnets[each.key].subnet.id
  keyvault_id     = module.keyvaults[each.key].keyvault.id
  storage_account = module.storage_account
}

module "keyvault_access_policies" {
  source   = "../../modules/key-vault/access-policy"
  for_each = local.apps

  keyvault_id                        = module.keyvaults[each.key].keyvault.id
  tenant_id                          = data.azurerm_client_config.current.tenant_id
  object_id                          = data.azurerm_client_config.current.object_id
  principal_id                       = module.apps[each.key].identity[0].principal_id
  general_keyvault_access_policies   = var.keyvault_access_policies.general
  principal_keyvault_access_policies = var.keyvault_access_policies.principal
}

module "keyvault_secrets" {
  source   = "../../modules/key-vault/secrets"
  for_each = local.keyvaults

  keyvault_id = module.keyvaults[each.key].keyvault.id
  secrets     = each.value.secrets
  keys        = each.value.keys

  depends_on = [module.keyvault_access_policies]
}

module "network_security_groups" {
  source = "../../modules/networking/ns-groups"

  environment         = local.environment
  resource_group_name = module.resource_group.env.name
  location            = module.resource_group.env.location
  subnets             = module.subnets
  custom_rules        = local.nsg_custom_rules

}

module "mysql_db" {
  source = "../../modules/databases/mysql"
  for_each = var.apps

  name                = each.value.name
  environment         = local.environment
  location            = module.resource_group.env.location
  resource_group_name = module.resource_group.env.name
  company             = var.company
  vnet_id             = azurerm_virtual_network.vnet.id
  private_ip          = each.value.db_ip
  keyvault_id         = module.keyvaults[each.key].keyvault.id
}