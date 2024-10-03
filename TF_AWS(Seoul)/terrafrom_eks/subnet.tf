# prd subnet 생성
resource "aws_subnet" "prd_pub_sub_a" {
  vpc_id                  = aws_vpc.prd_vpc.id
  cidr_block              = "10.250.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true # public IP 자동 할당

  tags = {
    Name = "prd_pub_sub_a"
  }
}

resource "aws_subnet" "prd_pub_sub_c" {
  vpc_id                  = aws_vpc.prd_vpc.id
  cidr_block              = "10.250.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true # Public IP 자동 할당

  tags = {
    Name = "prd_pub_sub_c"
  }
}

resource "aws_subnet" "prd_node_sub_a" {
  vpc_id            = aws_vpc.prd_vpc.id
  cidr_block        = "10.250.12.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "prd_node_sub_2a"
  }
}

resource "aws_subnet" "prd_node_sub_c" {
  vpc_id            = aws_vpc.prd_vpc.id
  cidr_block        = "10.250.22.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "prd-node-sub-2c"
  }
}

resource "aws_subnet" "prd_db_sub_a" {
  vpc_id            = aws_vpc.prd_vpc.id
  cidr_block        = "10.250.13.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "prd_db_sub_2a"
  }
}

resource "aws_subnet" "prd_db_sub_c" {
  vpc_id            = aws_vpc.prd_vpc.id
  cidr_block        = "10.250.23.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "prd_db_sub_2c"
  }
}

resource "aws_subnet" "prd_redis_sub_2a" {
  vpc_id            = aws_vpc.prd_vpc.id
  cidr_block        = "10.250.24.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "prd_redis_sub_2a"
  }
}

resource "aws_subnet" "prd_redis_sub_2c" {
  vpc_id            = aws_vpc.prd_vpc.id
  cidr_block        = "10.250.25.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "prd_redis_sub_2c"
  }
}

# dev subnet 생성
resource "aws_subnet" "dev_pub_sub_a" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.230.1.0/24"
  availability_zone       = "ap-northeast-2a"
  map_public_ip_on_launch = true # public IP 자동 할당

  tags = {
    Name = "dev_pub_sub_2a"
  }
}

resource "aws_subnet" "dev_pub_sub_c" {
  vpc_id                  = aws_vpc.dev_vpc.id
  cidr_block              = "10.230.2.0/24"
  availability_zone       = "ap-northeast-2c"
  map_public_ip_on_launch = true # Public IP 자동 할당

  tags = {
    Name = "dev_pub_sub_2c"
  }
}


resource "aws_subnet" "dev_node_sub_a" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.230.12.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "dev_node_sub_2a"
  }
}

resource "aws_subnet" "dev_node_sub_c" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.230.22.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "dev-node-sub-2c"
  }
}

resource "aws_subnet" "dev_db_sub_a" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.230.13.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "dev_db_sub_2a"
  }
}

resource "aws_subnet" "dev_db_sub_c" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.230.23.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "dev_db_sub_2c"
  }
}

resource "aws_subnet" "dev_redis_sub_2a" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.230.24.0/24"
  availability_zone = "ap-northeast-2a"

  tags = {
    Name = "dev_redis_sub_2a"
  }
}

resource "aws_subnet" "dev_redis_sub_2c" {
  vpc_id            = aws_vpc.dev_vpc.id
  cidr_block        = "10.230.25.0/24"
  availability_zone = "ap-northeast-2c"

  tags = {
    Name = "dev_redis_sub_2c"
  }
}