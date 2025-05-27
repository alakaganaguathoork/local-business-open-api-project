module "vnet" {
  source      = "../networking/vnet"
  environment = var.environment
  location    = var.location
  vpc_cidr    = var.vpc_cidr
  subnets     = local.subnets_to_create
}

module "ns_groups" {
  source      = "../networking/ns-groups"
  environment = var.environment
  location    = var.location
  subnet_ids  = module.vnet.subnets
  nsg_rules   = local.nsg_rules
}

module "apps" {
  depends_on = [module.vnet]

  source      = "../app-service"
  environment = var.environment
  location    = var.location
  apps        = local.apps
  subnet_ids     = module.vnet.subnets
}

module "keyvault" {
  depends_on = [module.vnet]

  source      = "../key-vault"
  environment = var.environment
  location    = var.location
  keyvaults   = local.keyvaults
  subnet      = module.vnet.subnets
}

module "dns" {
  source = "../networking/dns"
  environment = var.environment
  location = var.location
  private_dns_zone_name = "${var.environment}.mishap"
  vnet = module.vnet.vnet
  dns_a_records = module.keyvault.kv_private_endpoints
}