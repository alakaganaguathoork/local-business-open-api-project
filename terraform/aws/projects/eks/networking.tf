###
## Data
###
data "aws_availability_zones" "available" {
  state = "available"
}

###
## VPC, Subnets, IGW, NAT, EIP
###
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "${var.cluster.name}-${var.env}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    "Name"                                        = "${var.cluster.name}-public-subnet-${count.index}",
    "kubernetes.io/cluster/${var.cluster.name}" = "shared",
    "kubernetes.io/role/elb"         = "1"
  }
}

resource "aws_subnet" "private_subnet" {
  count = 2

  vpc_id            = aws_vpc.main.id
  map_public_ip_on_launch = true
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 10)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    "Name"                                        = "${var.cluster.name}-private-subnet-${count.index}",
    "kubernetes.io/cluster/${var.cluster.name}" = "shared",
    "kubernetes.io/role/internal-elb"         = "1" 
  }
}

locals {
  public_subnets  = { for idx, subnet in aws_subnet.public_subnet : idx => subnet }
  private_subnets = { for idx, subnet in aws_subnet.private_subnet : idx => subnet }
}

resource "aws_eip" "nat-eip" {
  for_each = local.public_subnets

  domain = "vpc"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "nat" {
  for_each = local.public_subnets

  subnet_id     = each.value.id
  allocation_id = aws_eip.nat-eip[each.key].id

  depends_on    = [ aws_internet_gateway.igw ]
}

###
## Routing
###
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private" {
  for_each = aws_nat_gateway.nat

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = each.value.id
  }
}

resource "aws_route_table_association" "public_assoc" {
  for_each = local.public_subnets

  subnet_id     = each.value.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_assoc" {
  for_each = local.private_subnets

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private[each.key].id
}