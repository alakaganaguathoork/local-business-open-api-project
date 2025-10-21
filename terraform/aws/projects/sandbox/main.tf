module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr_block  = var.vpc_cidr_block
  environment     = var.environment
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  enable_dns_hostnames = true
  enable_gateway       = true
  enable_nat           = true

  security_groups               = var.security_groups
  create_secretmanager_endpoint = true
}

module "secrets" {
  for_each = var.secrets
  source   = "git::https://github.com/alakaganaguathoork/local-business-open-api-project.git//terraform/aws/modules/secret-manager?ref=main"

  secret = each.value
}


module "security-groups" {
  source = "git::https://github.com/alakaganaguathoork/local-business-open-api-project.git//terraform/aws/modules/vpc/security-group?ref=main"

  vpc_id          = module.vpc.vpc_id
  security_groups = var.security_groups
}

output "sg" {
  # value = data.aws_security_groups.argocd.ids
  value = [ for sg in module.security-groups.groups : sg.id ]
}
