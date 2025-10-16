###
## Cluster
###
resource "aws_eks_cluster" "main" {
  name     = var.cluster.name
  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster.k8s_version

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = true
  }

  # bootstrap_self_managed_addons = false
  # 
  # compute_config {
  # enabled = false
  # }
  # 
  # kubernetes_network_config {
  # elastic_load_balancing {
  # enabled = false
  # }
  # }
  # 
  # storage_config {
  # block_storage {
  # enabled = false
  # }
  # }

  vpc_config {
    # endpoint_private_access = false
    # endpoint_public_access  = true
    subnet_ids = concat(aws_subnet.private_subnet[*].id, aws_subnet.public_subnet[*].id)
    # security_group_ids = [ aws_security_group.eks_cluster_sg.id ]
    # security_group_ids = [module.security_groups.groups["cluster"].id]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSNetworkingPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSServicePolicy,
  ]
}

###
## Cluster addons
###
data "aws_eks_addon_version" "main" {
  for_each = var.cluster_addons

  addon_name         = each.value.addon_name
  kubernetes_version = aws_eks_cluster.main.version
}

resource "aws_eks_addon" "main" {
  for_each = var.cluster_addons

  cluster_name                = aws_eks_cluster.main.name
  addon_name                  = each.value.addon_name
  addon_version               = data.aws_eks_addon_version.main[each.key].version
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  depends_on = [
    aws_eks_node_group.custom
  ]
}

###
## Connect to cluster
###
resource "null_resource" "post-script" {
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.main.name}"
  }

  depends_on = [aws_eks_access_policy_association.access_users]
}

###
## Node group
###
resource "aws_key_pair" "local" {
  key_name   = "my-shh-key"
  public_key = var.my_public_ssh_key
}

data "aws_ssm_parameter" "eks_worker_ami" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.main.version}/amazon-linux-2023/x86_64/standard/recommended/image_id"
  # name = /aws/service/eks/optimized-ami/1.33/amazon-linux-2023/x86_64/standard/recommended/image_id
}

# Using Launch Template to set security group and other parameters not supported by aws_eks_node_group
resource "aws_launch_template" "node" {
  name_prefix = "${var.cluster.name}-node"
  image_id    = data.aws_ssm_parameter.eks_worker_ami.value
  key_name    = aws_key_pair.local.key_name

  # hop_limit 2 is required for v2 in kubernetes YAML files
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  network_interfaces {
    associate_public_ip_address = false
    # security_groups             = [aws_security_group.eks_nodes_sg.id]
  }

  vpc_security_group_ids = [module.security_groups.groups["node"].id]

  # https://docs.aws.amazon.com/eks/latest/userguide/launch-templates.html#launch-template-user-data
  user_data = base64encode(<<EOF
    ---
    apiVersion: node.eks.aws/v1alpha1
    kind: NodeConfig
    spec:
      cluster:
        name: ${aws_eks_cluster.main.name}
        apiServerEndpoint: ${aws_eks_cluster.main.endpoint}
        certificateAuthority: ${aws_eks_cluster.main.certificate_authority[0].data}
        cidr:  ${aws_eks_cluster.main.kubernetes_network_config[0].service_ipv4_cidr}  
    EOF
  )

  tags = {
    "Name"                                      = "${var.cluster.name}-eks-node-group"
    "kubernetes.io/cluster/${var.cluster.name}" = "owned"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_eks_node_group" "custom" {
  for_each = var.node_groups

  node_group_name      = each.key
  cluster_name         = aws_eks_cluster.main.name
  node_role_arn        = aws_iam_role.node.arn
  instance_types       = each.value.instance_types
  subnet_ids           = aws_subnet.private_subnet[*].id
  force_update_version = true

  update_config {
    max_unavailable = 1
  }

  scaling_config {
    min_size     = each.value.scaling_config.min_size
    max_size     = each.value.scaling_config.max_size
    desired_size = each.value.scaling_config.desired_size
  }

  launch_template {
    id      = aws_launch_template.node.id
    version = "$Latest"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
    # aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryPullOnly,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
  ]

  tags = {
    "kubernetes.io/cluster/${var.cluster.name}" = "owned"
  }
}
