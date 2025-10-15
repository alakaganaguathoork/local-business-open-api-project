output "cluster_name" {
  value = aws_eks_cluster.main.name
}

output "sg_custom" {
  value = data.aws_security_groups.custom.ids
}

output "sg_argocd" {
  value = data.aws_security_groups.argocd.ids
}