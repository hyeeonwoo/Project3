# prd subnet 생성
# Public 서브넷 (us-east-1a)
resource "aws_subnet" "onprem_public" {
  vpc_id                  = aws_vpc.onprem_vpc.id
  cidr_block              = "10.240.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # public IP 자동 할당

  tags = {
    Name = "onprem_pub_sub"
  }
}

resource "aws_subnet" "onprem_public_1b" {
  vpc_id                  = aws_vpc.onprem_vpc.id
  cidr_block              = "10.240.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true # public IP 자동 할당

  tags = {
    Name = "onprem_public-1b"
  }
}

# Private 서브넷 (us-east-1a) - 마스터 및 워커 노드를 위한 서브넷
resource "aws_subnet" "onprem_private" {
  vpc_id                  = aws_vpc.onprem_vpc.id
  cidr_block              = "10.240.2.0/24"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "onprem_pri_sub"
  }
}



