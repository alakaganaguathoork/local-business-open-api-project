###
## Data
###
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_eks_cluster" "main" {
  name = aws_eks_cluster.main.name
}

data "aws_eks_cluster_auth" "main" {
  name = aws_eks_cluster.main.name
}

data "aws_caller_identity" "current" {
}

###
## Networking
###
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
}

resource "aws_subnet" "subnet" {
  # provisions subnets dynamically with `count`, not from `input_data` 
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster.name}" = "owned"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  count          = 2
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.public.id
}

###
## Security groups
###
module "security-groups" {
  source = "git::https://github.com/alakaganaguathoork/local-business-open-api-project.git//terraform/aws/modules/vpc/security-group?ref=main"

  vpc_id = aws_vpc.main.id
  security_groups = var.security_groups
}

###
## Roles and policies
###
resource "aws_iam_role" "node" {
  name = "eks-auto-node"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["sts:AssumeRole"]
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodeMinimalPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodeMinimalPolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

# Cluster IAM role
resource "aws_iam_role" "cluster" {
  name = "eks-cluster"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "cluster_lb" {
  name        = "eks-cluster-lb"
  description = "Permissions for EKS cluster to manage Load Balancers"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "LoadBalancer"
        Effect = "Allow"
        Action = [
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:Modify*",
          "elasticloadbalancing:Describe*",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:Describe*"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestTag/eks:eks-cluster-name" = "$${aws:PrincipalTag/eks:eks-cluster-name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_lb_attach" {
  policy_arn = aws_iam_policy.cluster_lb.arn
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSComputePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSNetworkingPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}

###
## Cluster
###
resource "aws_eks_cluster" "main" {
  name   = var.cluster.name
  region = var.region

  access_config {
    authentication_mode = "API"
  }

  role_arn = aws_iam_role.cluster.arn
  version  = var.cluster.k8s_version

  bootstrap_self_managed_addons = false

  compute_config {
    enabled       = true
    node_pools    = ["general-purpose"]
    node_role_arn = aws_iam_role.node.arn
  }

  kubernetes_network_config {
    elastic_load_balancing {
      enabled = true
    }
  }

  storage_config {
    block_storage {
      enabled = true
    }
  }

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    subnet_ids              = aws_subnet.subnet[*].id
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
## Access management
###
resource "aws_eks_access_entry" "access_users" {
  for_each = { for users in var.access_users : users => users }

  cluster_name  = aws_eks_cluster.main.name
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

###
## Connect to cluster
###
# resource "null_resource" "post-script" {
  # provisioner "local-exec" {
    # command = "aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.main.name}"
  # }
# 
  # depends_on = [aws_eks_access_policy_association.access_users]
# }

###
## Create s3 buckets for Loki
###
output "cluster" {
  value = data.aws_eks_cluster.main
}


output "oidc_issuer" {
  value = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
}


# resource "aws_iam_openid_connect_provider" "eks" {
  # url = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  # client_id_list = [ data.aws_eks_cluster.main.id ]
# }

# data "aws_iam_openid_connect_provider" "eks" {
  # arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
# }

# resource "aws_eks_identity_provider_config" "example" {
  # cluster_name = aws_eks_cluster.main.name
# 
  # oidc {
    # client_id                     = "your client_id"
    # identity_provider_config_name = "eks-provider"
    # issuer_url                    = data.aws_eks_cluster.main.identity[0].oidc[0].issuer
  # }
# }

# resource "aws_iam_role" "loki" {
  # name = "FederatedAccessForLoki"
  # assume_role_policy = jsonencode({
    # Version = "2012-10-17",
    # Statement = [
      # {
        # Effect = "Allow",
        # Principal = {
          # Federated = data.aws_iam_openid_connect_provider.eks.arn
        # },
        # Action = "sts:AssumeRoleWithWebIdentity",
        # Condition = {
          # StringEquals = {
            # "${data.aws_eks_cluster.main.identity[0].oidc[0].issuer}:sub" = "system:serviceaccount:loki:loki",
            # "${data.aws_eks_cluster.main.identity[0].oidc[0].issuer}:aud" = "sts.amazonaws.com"
          # }
        # }
      # }
    # ]
  # })
# }
# 
# resource "aws_iam_policy" "loki-s3" {
  # name        = "AccessToS3ForLoki"
  # description = "Allow Loki to read/write logs and alerts buckets"
# 
  # policy = jsonencode({
    # Version = "2012-10-17",
    # Statement = [
      # {
        # Sid    = "LokiStorageAccess",
        # Effect = "Allow",
        # Action = [
          # "s3:ListBucket",
          # "s3:GetObject",
          # "s3:PutObject",
          # "s3:DeleteObject"
        # ],
        # Resource = [
          # "arn:aws:s3:::${var.buckets["logs"].name}",
          # "arn:aws:s3:::${var.buckets["logs"].name}/*",
          # "arn:aws:s3:::${var.buckets["alerts"].name}",
          # "arn:aws:s3:::${var.buckets["alerts"].name}/*"
        # ]
      # }
    # ]
  # })
# }
# 
# resource "aws_iam_role_policy_attachment" "loki-s3" {
  # role       = aws_iam_role.loki.name
  # policy_arn = aws_iam_policy.loki-s3.arn
# }


# resource "aws_s3_bucket" "name" {
  # for_each = var.buckets
# 
  # bucket = each.value["name"]
# }