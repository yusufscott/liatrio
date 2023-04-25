resource "aws_vpc" "liatrio_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "Liatrio VPC"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

#Subnets
resource "aws_subnet" "liatrio_cluster_subnets" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.liatrio_vpc.cidr_block, 8, count.index)
  vpc_id            = aws_vpc.liatrio_vpc.id
  map_public_ip_on_launch = true

  tags = {
    "Name" = "Liatrio Cluster Subnet ${count.index}"
  }
}

resource "aws_subnet" "liatrio_node_subnets" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.liatrio_vpc.cidr_block, 8, count.index+2)
  vpc_id            = aws_vpc.liatrio_vpc.id

  tags = {
    "Name" = "Liatrio Node Subnet ${count.index}"
    "kubernetes.io/cluster/${aws_eks_cluster.liatrio_cluster.name}" = "shared"
  }
}

#Gateways
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.liatrio_vpc.id

  tags = {
    Name = "Liatrio IG"
  }
}

resource "aws_nat_gateway" "liatrio_nat" {
  count = 2
  connectivity_type = "private"
  subnet_id         = aws_subnet.liatrio_node_subnets[count.index].id
}

#Route Tables
data "aws_route_table" "main_rt" {
  vpc_id = aws_vpc.liatrio_vpc.id
  filter {
    name = "association.main"
    values = [ "true" ]
  }
}

resource "aws_route" "r" {
  route_table_id            = data.aws_route_table.main_rt.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.gw.id
}

resource "aws_route_table" "subnet_route_tables" {
  count = 2
  vpc_id = aws_vpc.liatrio_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.liatrio_nat[count.index].id
  }

  tags = {
    Name = "Liatrio RT ${count.index}"
  }
}

resource "aws_route_table_association" "a" {
  count = 2
  subnet_id      = aws_subnet.liatrio_node_subnets[count.index].id
  route_table_id = aws_route_table.subnet_route_tables[count.index].id
}

#Endpoints
resource "aws_security_group" "liatrio_endpoint_sg" {
  name        = "Liatrio Endpoint SG"
  description = "Allow traffic to endpoints"
  vpc_id      = aws_vpc.liatrio_vpc.id

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    security_groups  = [aws_eks_cluster.liatrio_cluster.vpc_config[0].cluster_security_group_id]
  }

  ingress {
    from_port        = 3128
    to_port          = 3128
    protocol         = "tcp"
    security_groups  = [aws_eks_cluster.liatrio_cluster.vpc_config[0].cluster_security_group_id]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Liatrio Endpoint SG"
  }
}

resource "aws_vpc_endpoint" "ec2" {
  vpc_id       = aws_vpc.liatrio_vpc.id
  service_name = "com.amazonaws.us-east-1.ec2"
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.liatrio_node_subnets[*].id

  security_group_ids = [
    aws_security_group.liatrio_endpoint_sg.id,
  ]
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id       = aws_vpc.liatrio_vpc.id
  service_name = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.liatrio_node_subnets[*].id

  security_group_ids = [
    aws_security_group.liatrio_endpoint_sg.id,
  ]
}

resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id       = aws_vpc.liatrio_vpc.id
  service_name = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.liatrio_node_subnets[*].id

  security_group_ids = [
    aws_security_group.liatrio_endpoint_sg.id,
  ]
}

resource "aws_vpc_endpoint" "sts" {
  vpc_id       = aws_vpc.liatrio_vpc.id
  service_name = "com.amazonaws.us-east-1.sts"
  vpc_endpoint_type = "Interface"
  subnet_ids = aws_subnet.liatrio_node_subnets[*].id

  security_group_ids = [
    aws_security_group.liatrio_endpoint_sg.id,
  ]
}