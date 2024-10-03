# Virginia 리전
provider "aws" {
  region = "us-east-1"
}

# PRD VPC 생성
resource "aws_vpc" "onprem_vpc" {
  cidr_block           = "10.240.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "onprem_vpc"
  }
}


# onprem IGW 생성
resource "aws_internet_gateway" "onprem_igw" {
  vpc_id = resource.aws_vpc.onprem_vpc.id
  tags = {
    Name = "onprem_igw"
  }
}


# onprem-EIP 생성
resource "aws_eip" "onprem_nat_eip" {
  vpc = true

  tags = {
    Name = "onprem_nat_eip"
  }
}


# onprem NAT 생성
resource "aws_nat_gateway" "onprem_nat" {
  allocation_id = aws_eip.onprem_nat_eip.id
  subnet_id     = aws_subnet.onprem_public.id

  tags = {
    Name = "onprem_nat"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.onprem_igw]
}


# onprem Public rtb
resource "aws_route_table" "onprem_pub_rt" {
  vpc_id = aws_vpc.onprem_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.onprem_igw.id
  }

  route {
  cidr_block = "10.250.0.0/16"  # 서울 리전 CIDR
  network_interface_id = aws_instance.vpn_gateway_instance.primary_network_interface_id  # 버지니아 Libreswan 인스턴스의 네트워크 인터페이스 ID
  }

  route {
    cidr_block = aws_vpc.onprem_vpc.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "onprem_pub_rt"
  }
}



# onprem Private rtb
resource "aws_route_table" "onprem_pri_rt" {
  vpc_id = aws_vpc.onprem_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.onprem_nat.id
  }

  tags = {
    Name = "onprem_pri_rt"
  }
  depends_on = [aws_nat_gateway.onprem_nat]
}


# onprem rtb association
resource "aws_route_table_association" "onprem_pub_association" {
  subnet_id      = aws_subnet.onprem_public.id
  route_table_id = aws_route_table.onprem_pub_rt.id

  depends_on = [ aws_route_table.onprem_pub_rt ]
}


resource "aws_route_table_association" "onprem_db_pri_association" {
  subnet_id      = aws_subnet.onprem_private.id
  route_table_id = aws_route_table.onprem_pri_rt.id
}
