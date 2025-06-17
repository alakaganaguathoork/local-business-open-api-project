output "sg" {
  value = aws_security_group.sg
}

output "ingress_rule" {
  value = aws_vpc_security_group_ingress_rule.allow_tls_ipv4
}

output "egress_rule" {
  value = aws_vpc_security_group_egress_rule.allow_all_traffic_ipv4
}