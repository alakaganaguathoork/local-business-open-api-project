resource "aws_security_group" "sg" {
  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress_rule" {
  for_each = var.ingress_rule

  security_group_id              = aws_security_group.sg.id
  cidr_ipv4                      = each.value.cidr_ipv4
  from_port                      = lookup(each.value, "from_port", null)
  ip_protocol                    = each.value.ip_protocol
  to_port                        = lookup(each.value, "to_port", null)
}

resource "aws_vpc_security_group_egress_rule" "egress_rule" {
  for_each = var.egress_rule

  security_group_id              = aws_security_group.sg.id
  cidr_ipv4                      = each.value.cidr_ipv4
  from_port                      = lookup(each.value, "from_port", null)
  ip_protocol                    = each.value.ip_protocol
  to_port                        = lookup(each.value, "to_port", null)
}            