module "networking" {
  source = "../../modules/networking"

  vpc_cidr_block = var.vpc_cidr_block
  public_subnets = local.subnets
  enable_gateway = true
  enable_nat = false
}

locals {
  security_groups_old = {
    # allow_tls = {
      # name        = "Allow TLS"
      # description = "Allow secure connections in subnets"
      # ingress_rule = {
        # for key, value in var.subnets :
        # key => {
          # cidr_ipv4   = value.subnet_cidr
          # from_port   = 443
          # ip_protocol = "tcp"
          # to_port     = 443
        # }
      # }
      # egress_rule = {
        # allow_all = {
          # cidr_ipv4   = "0.0.0.0/0"
          # ip_protocol = "-1" # semantically equivalent to all ports 
        # }
      # }
    # }
    app_runner = {
      name = "App Runner SG"
      description = "Allow App Runner health check on port 8080"
      ingress_rule = {
        for key, value in local.subnets :
        key => {
          # from_port                 = 0
          # to_port                   = 80
          ip_protocol               = "-1"
          cidr_ipv4                 = "0.0.0.0/0"
        }
      }
      egress_rule = {
        allow_all = {
          ip_protocol    = "-1"
          cidr_ipv4 = "0.0.0.0/0"
        }
      }
    }
  }
}

# Security Groups
module "security_groups" {
  source   = "../../modules/networking/security-group"
  for_each = local.security_groups
  
  name         = each.value.name
  description  = each.value.description
  vpc_id       = module.networking.vpc_id
  ingress_rule = each.value.ingress_rule
  egress_rule  = each.value.egress_rule
}

module "ecr" {
  source = "../../modules/ecr"
  providers = {
    docker = docker.main
  }
  for_each = var.apps

  region = var.region
  app_name = each.value.name
  build_context = var.build_context
  image_tag = each.value.image_tag
}

module "app_runner" {
  source = "../../modules/app-runner"
  for_each = var.apps

  region = var.region
  app_name = each.value.name
  image_identifier = module.ecr[each.key].image_identifier
  subnet_id = module.networking.public_subnets[each.key].id
  security_group_id = [for value in values(module.security_groups) : value.sg.id]
  repository_url = module.ecr[each.key].repository_url

  depends_on = [ module.networking.ingress_rule ]
}