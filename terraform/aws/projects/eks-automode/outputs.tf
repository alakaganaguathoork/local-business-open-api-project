output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "security_groups" {
  value = module.security-groups.groups[*]
}

output "cluster" {
  value = data.aws_eks_cluster.main
}

output "oidc_issuer_url" {
  value = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
}