###
## Access management
###
resource "aws_eks_access_entry" "access_users" {
  for_each = { for users in var.access_users : users => users }

  cluster_name = aws_eks_cluster.main.name
  principal_arn = each.value
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "access_users" {
  for_each = aws_eks_access_entry.access_users
  
  cluster_name  = aws_eks_cluster.main.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = each.value.principal_arn
  access_scope {
    type = "cluster"
  }
}
