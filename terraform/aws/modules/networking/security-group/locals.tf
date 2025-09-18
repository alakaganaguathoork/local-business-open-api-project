locals {
  sg_rules_list = flatten([
    for sg_name, rules in var.security_groups : [
      for rule_name, rule in rules : {
        key        = "${sg_name}-${rule_name}"   # unique key
        sg_name    = sg_name
        type       = rule.type
        from_port  = rule.from_port
        to_port    = rule.to_port
        protocol   = rule.protocol
        cidr_blocks = lookup(rule, "cidr_blocks", null)
        source_security_group_name   = lookup(rule, "source_security_group_name", null)
      }
    ]
  ])

  sg_rules = { for r in local.sg_rules_list : r.key => r } # Turn flattened list into a map suitable for for_each
}