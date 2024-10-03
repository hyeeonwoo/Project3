# prd bastion security group
resource "aws_security_group" "prd_bastion_security" {
  name        = "ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.prd_vpc.id # 내가 생성한 VPC

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1           # ICMP 전체 허용 (ping 포함)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.230.0.0/16"]  # dev VPC CIDR (피어링된 VPC로부터의 요청을 허용)
  }

    ingress {
    from_port   = -1           # ICMP 전체 허용 (ping 포함)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.240.0.0/16"]  # on-premise VPC CIDR (피어링된 VPC로부터의 요청을 허용)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "prd-bastion-sg"
  }
}

# dev bastion security group
resource "aws_security_group" "dev_bastion_security" {
  name        = "ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.dev_vpc.id # 내가 생성한 VPC

  ingress {
    description = "SSH from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1           # ICMP 전체 허용 (ping 포함)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.250.0.0/16"]  # dev VPC CIDR (피어링된 VPC로부터의 요청을 허용)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "dev-bastion-sg"
  }
}

# jenkins security group
resource "aws_security_group" "jenkins_security" {
  name        = "jenkins"
  description = "Allow ALL traffic"
  vpc_id      = aws_vpc.prd_vpc.id # 내가 생성한 VPC

  ingress {
    description = "ALL traffic from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1           # ICMP 전체 허용 (ping 포함)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.240.0.0/16"]  # on-premise VPC CIDR (피어링된 VPC로부터의 요청을 허용)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "jenkins_sg"
  }
}

# monitoring security group
/*resource "aws_security_group" "prd_monitoring_security" {
  name        = "monitoring"
  description = "Allow ALL traffic"
  vpc_id      = aws_vpc.prd_vpc.id # 내가 생성한 VPC

  ingress {
    description = "ALL traffic from VPC"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "prd_monitoring_sg"
  }
} */

# prd db security
resource "aws_security_group" "prd_db_security" {
  name_prefix = "prd_db"
  description = "Allow db inbound traffic"
  vpc_id      = aws_vpc.prd_vpc.id # 내가 생성한 VPC

  ingress {
    description = "mysql from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1           # ICMP 전체 허용 (ping 포함)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.240.0.0/16"]  # on-premise VPC CIDR (피어링된 VPC로부터의 요청을 허용)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prd_allow_mysql_db"
  }
}

# dev db security
resource "aws_security_group" "dev_db_security" {
  name_prefix = "dev_db"
  description = "Allow db inbound traffic"
  vpc_id      = aws_vpc.dev_vpc.id # 내가 생성한 VPC

  ingress {
    description = "mysql from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "dev_allow_mysql_db"
  }
}

# EFS 보안 그룹
resource "aws_security_group" "efs_security" {
  name        = "efs-sg"
  description = "Allow NFS traffic for EFS"
  vpc_id      = aws_vpc.prd_vpc.id # 생성한 VPC ID 사용

  # EFS와의 통신을 허용하는 인바운드 규칙
  ingress {
    description = "NFS from VPC"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["10.250.0.0/16"] # VPC 내부의 IP 대역을 지정
  }

  ingress {
    from_port   = -1           # ICMP 전체 허용 (ping 포함)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.240.0.0/16"]  # on-premise VPC CIDR (피어링된 VPC로부터의 요청을 허용)
  }

  # 아웃바운드 트래픽을 모든 곳으로 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "efs-security-group"
  }
}
