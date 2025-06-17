output "subnets" {
  value = {
    for key, value in module.vpc.subnets :
    key => value.subnet.cidr_block
  }
}

output "security_groups" {
  value = {
    for key, value in module.vpc.security_groups :
    key => value.sg.id
  }
}