# PRD VPC 생성
resource "aws_vpc" "prd_vpc" {
  cidr_block           = "10.250.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "prd_vpc"
  }
}

# DEV VPC 생성
resource "aws_vpc" "dev_vpc" {
  cidr_block           = "10.230.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "dev_vpc"
  }
}

# PRD IGW 생성
resource "aws_internet_gateway" "prd_igw" {
  vpc_id = resource.aws_vpc.prd_vpc.id
  tags = {
    Name = "prd_igw"
  }
}

# DEV IGW 생성
resource "aws_internet_gateway" "dev_igw" {
  vpc_id = resource.aws_vpc.dev_vpc.id
  tags = {
    Name = "dev_igw"
  }
}

# PRD-EIP-2a 생성
resource "aws_eip" "prd_nat_eip_2a" {
  vpc = true

  tags = {
    Name = "prd_nat_eip_2a"
  }
}

# DEV-EIP 생성-2a
resource "aws_eip" "dev_nat_eip_2a" {
  vpc = true

  tags = {
    Name = "dev_nat_eip_2a"
  }
}


# PRD NAT-2a 생성
resource "aws_nat_gateway" "prd_nat" {
  allocation_id = aws_eip.prd_nat_eip_2a.id
  subnet_id     = aws_subnet.prd_pub_sub_a.id

  tags = {
    Name = "prd_nat_2a"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.prd_igw]
}

# DEV NAT 2a 생성
resource "aws_nat_gateway" "dev_nat_2a" {
  allocation_id = aws_eip.dev_nat_eip_2a.id
  subnet_id     = aws_subnet.dev_pub_sub_a.id

  tags = {
    Name = "dev_nat_2a"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.dev_igw]
}

# prd Public rtb
resource "aws_route_table" "prd_pub_rt" {
  vpc_id = aws_vpc.prd_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prd_igw.id
  }

  route {
    cidr_block = "10.250.0.0/16"  # 서울 리전 CIDR
    gateway_id = "local"
  }

  route {
    cidr_block = "10.240.0.0/16"  # 버지니아 리전 CIDR
    gateway_id = aws_vpn_gateway.prd_vpn_gw.id
  }

  route {
    cidr_block = "10.230.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.prd_dev_peer.id
  }

  tags = {
    Name = "prd_pub_rt"
  }
}

# dev Public rtb
resource "aws_route_table" "dev_pub_rt" {
  vpc_id = aws_vpc.dev_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.dev_igw.id
  }

  route {
    cidr_block = "10.250.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.prd_dev_peer.id
  }

  tags = {
    Name = "dev_pub_rt"
  }
}

# prd Private rtb
resource "aws_route_table" "prd_pri_rt_a" {
  vpc_id = aws_vpc.prd_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.prd_nat.id
  }

  tags = {
    Name = " prd_pri_rt_2a"
  }
  depends_on = [aws_nat_gateway.prd_nat]
}

resource "aws_route_table" "prd_pri_rt_c" {
  vpc_id = aws_vpc.prd_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.prd_nat.id
  }

  tags = {
    Name = " prd_pri_rt_2c"
  }
  depends_on = [aws_nat_gateway.prd_nat]
}

# dev Private rtb
resource "aws_route_table" "dev_pri_rt_a" {
  vpc_id = aws_vpc.dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dev_nat_2a.id
  }

  tags = {
    Name = " dev_pri_rt_2a"
  }
  depends_on = [aws_nat_gateway.dev_nat_2a]
}

# dev Private rtb
resource "aws_route_table" "dev_pri_rt_c" {
  vpc_id = aws_vpc.dev_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.dev_nat_2a.id
  }

  tags = {
    Name = " dev_pri_rt_2c"
  }
  depends_on = [aws_nat_gateway.dev_nat_2a]
}

# prd rtb association
resource "aws_route_table_association" "prd_pub_a" {
  subnet_id      = aws_subnet.prd_pub_sub_a.id
  route_table_id = aws_route_table.prd_pub_rt.id
}

resource "aws_route_table_association" "prd_pub_c" {
  subnet_id      = aws_subnet.prd_pub_sub_c.id
  route_table_id = aws_route_table.prd_pub_rt.id
}

resource "aws_route_table_association" "prd_node_sub_a" {
  subnet_id      = aws_subnet.prd_node_sub_a.id
  route_table_id = aws_route_table.prd_pri_rt_a.id
}

resource "aws_route_table_association" "prd_node_sub_c" {
  subnet_id      = aws_subnet.prd_node_sub_c.id
  route_table_id = aws_route_table.prd_pri_rt_c.id
}

resource "aws_route_table_association" "prd_db_pri_a" {
  subnet_id      = aws_subnet.prd_db_sub_a.id
  route_table_id = aws_route_table.prd_pri_rt_a.id
}

resource "aws_route_table_association" "prd_db_pri_c" {
  subnet_id      = aws_subnet.prd_db_sub_c.id
  route_table_id = aws_route_table.prd_pri_rt_c.id
}

# dev rtb association
resource "aws_route_table_association" "dev_pub_a" {
  subnet_id      = aws_subnet.dev_pub_sub_a.id
  route_table_id = aws_route_table.dev_pub_rt.id
}

resource "aws_route_table_association" "dev_pub_c" {
  subnet_id      = aws_subnet.dev_pub_sub_c.id
  route_table_id = aws_route_table.dev_pub_rt.id
}

resource "aws_route_table_association" "dev_node_sub_a" {
  subnet_id      = aws_subnet.dev_node_sub_a.id
  route_table_id = aws_route_table.dev_pri_rt_a.id
}

resource "aws_route_table_association" "dev_node_sub_c" {
  subnet_id      = aws_subnet.dev_node_sub_c.id
  route_table_id = aws_route_table.dev_pri_rt_c.id
}

resource "aws_route_table_association" "dev_db_pri_a" {
  subnet_id      = aws_subnet.dev_db_sub_a.id
  route_table_id = aws_route_table.dev_pri_rt_a.id
}

resource "aws_route_table_association" "dev_db_pri_c" {
  subnet_id      = aws_subnet.dev_db_sub_c.id
  route_table_id = aws_route_table.dev_pri_rt_c.id
}