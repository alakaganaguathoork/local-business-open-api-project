locals {

  # ecr_registry_url = module.ecr[0].repository_url

  subnets = { 
    for key, value in var.apps :  
      key => {
        subnet_cidr = value.subnet
    } 
  }
}

locals {
  # 1) produce a flat list of all (app,port) rule infos
  app_runner_rules = flatten([
    for app_key, app in var.apps : [
      for port in app.allow_ingress_connections_on_ports : {
        key       = "${app_key}-${port}"
        from_port = port
        to_port   = port
        protocol  = "tcp"
        cidr      = app.subnet
      }
    ]
  ])

  # 2) turn that list into the map your module expects
  security_groups = {
    app_runner = {
      name        = "App Runner SG"
      description = "Allow App Runner health checks on specified ports"

      ingress_rule = {
        for r in local.app_runner_rules :
        r.key => {
          from_port   = r.from_port
          to_port     = r.to_port
          ip_protocol = r.protocol
          cidr_ipv4   = r.cidr
        }
      }

      egress_rule = {
        allow_all = {
          ip_protocol = "-1"
          cidr_ipv4   = "0.0.0.0/0"
        }
      }
    }
  }
}
