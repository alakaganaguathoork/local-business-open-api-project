output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "security_groups" {
  value = module.security-groups.groups[*]
}