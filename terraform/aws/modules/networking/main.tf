resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "terraform"
  }
}


resource "aws_subnet" "public_subnets" {
  for_each = var.public_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.subnet_cidr

  tags = {
    Name = "public_${each.value.subnet_cidr}"
  }
}

resource "aws_subnet" "private_subnets" {
  for_each = var.private_subnets

  vpc_id = aws_vpc.main.id
  cidr_block = each.value.subnet_cidr

  tags = {
    Name = "private_${each.value.subnet_cidr}"
  }
}

resource "aws_internet_gateway" "igw" {
  for_each = aws_subnet.public_subnets

  vpc_id = aws_vpc.main.id


  tags = {
    Name = "igw_${aws_vpc.main.tags["Name"]}"
  }
}

resource "aws_nat_gateway" "ngw" {
  for_each = aws_subnet.private_subnets

  subnet_id = each.value.id
  tags = {
    Name = "nat_${each.value.cidr_ipv4}"
  }
}

resource "aws_route_table" "rt_public" {
  for_each = aws_subnet.public_subnets

  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "rt_public_${aws_vpc.main.tags["Name"]}"
  }
}


resource "aws_route_table" "rt_private" {
  for_each = aws_subnet.private_subnets

  vpc_id   = aws_vpc.main.id

  tags = {
    Name = "rt_private_${aws_vpc.main.tags["Name"]}"
  }
}

resource "aws_route_table_association" "a_public" {
  for_each =  aws_subnet.public_subnets

  #subnet_id      = aws_subnet.public_subnets[each.key].id
  route_table_id = aws_route_table.rt_public[each.key].id
  gateway_id = aws_internet_gateway.igw[each.key].id
}

resource "aws_route_table_association" "a_private" {
  for_each = aws_subnet.private_subnets

  subnet_id      = aws_subnet.private_subnets[each.key].id
  route_table_id = aws_route_table.rt_private[each.key].id
  #gateway_id = aws_nat_gateway.ngw[each.key].id
}
