###
## Data
###
data "aws_eks_cluster" "main" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "main" {
  name = var.cluster_name
}

data "aws_security_groups" "eks" {
  filter {
    name   = "vpc-id"
    values = [data.aws_eks_cluster.main.vpc_config[0].vpc_id]
  }
}

###
## Deployment
###
locals {
  nginx_namespace_manifest = yamldecode(file("yamls/namespace.yml"))
  nginx_deployment_manifest_nginx = yamldecode(file("yamls/deployments/nginx/deployment.yml"))

  # Security group ids are passed as a comma-separated string to the template from data source
  nginx_service_manifest_loadbalancer = yamldecode(templatefile("yamls/services/nginx/lb.yml.tpl", { 
    sg_ids = join(",", data.aws_security_groups.eks.ids) 
    }
  ))
  # nginx_network_policy_manifest_ingress_deny_all = yamldecode(file("yamls/network-policy/nginx/ingress-deny-all.yml"))
  # nginx_network_policy_manifest_ingress_allow_static_ip = yamldecode(file("yamls/network-policy/nginx/ingress-allow-static-ip.yml"))
}

resource "kubernetes_manifest" "namespace" {
  manifest = local.nginx_namespace_manifest
}

resource "kubernetes_manifest" "deployment" {
  manifest = local.nginx_deployment_manifest_nginx
}

resource "kubernetes_manifest" "service" {
  manifest = local.nginx_service_manifest_loadbalancer
}

# Kubernetes Network Policies have not effect in EKS Auto mode
# resource "kubernetes_manifest" "network_policy_ingress_deny_all" {
  # manifest = local.nginx_network_policy_manifest_ingress_deny_all
# }
# 
# resource "kubernetes_manifest" "network_policy_ingress_allow_static_ip" {
  # manifest = local.nginx_network_policy_manifest_ingress_allow_static_ip
# }

output "lb_endpoint" {
  value = kubernetes_manifest.service.status[0].load_balancer[0].ingress[0].hostname
}