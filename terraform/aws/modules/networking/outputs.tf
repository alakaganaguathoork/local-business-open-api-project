output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "subnets" {
  value = module.subnet
}

output "security_groups" {
  value = module.security_group
}