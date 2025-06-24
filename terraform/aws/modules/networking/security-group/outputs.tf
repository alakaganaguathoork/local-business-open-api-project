output "sg" {
  value = aws_security_group.sg
}

output "ingress_rule" {
  value = aws_vpc_security_group_ingress_rule.ingress_rule
}

output "egress_rule" {
  value = aws_vpc_security_group_egress_rule.egress_rule
}