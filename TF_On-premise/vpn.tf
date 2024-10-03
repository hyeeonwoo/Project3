# PRD용 vpn 보안 그룹 생성
resource "aws_security_group" "onprem_vpn_sg" {
  name        = "onprem-vpn-sg"
  description = "Security group for onprem VPN"
  vpc_id      = aws_vpc.onprem_vpc.id

  ingress {
    from_port   = 50
    to_port     = 50
    protocol    = "50"  # ESP 프로토콜 (IP 프로토콜 번호 50)
    cidr_blocks = ["10.250.0.0/16"]  # 상대 리전의 VPC CIDR
  }

  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["10.250.0.0/16"]  # Seoul 대역
  }

  ingress {
   from_port   = -1
   to_port     = -1
   protocol    = "icmp"
   cidr_blocks = ["10.250.0.0/16"]  # 상대 리전의 VPC CIDR
 }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["10.250.0.0/16"]  # Seoul 대역
  }

  # DB 통신 허용
  ingress {
    description = "mysql from VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }    

  # SSH 포트 허용 (관리용)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.250.0.0/16"]  # 버지니아 리전 VPC CIDR
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # 모든 트래픽 허용
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "onprem-vpn-sg"
  }
}



# Amazon Linux 2 AMI 검색 
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]  # Amazon 소유자 ID

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]  # 올바른 이름 패턴
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]  # 아키텍처 설정
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]  # EBS 루트 디바이스 타입
  }
}

# EC2 인스턴스 생성 (VPN을 위한 고객 게이트웨이 역할)
resource "aws_instance" "vpn_gateway_instance" {
  ami           = data.aws_ami.amazon_linux.id  # 검색된 AMI ID 사용
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.onprem_public.id
  vpc_security_group_ids = [aws_security_group.onprem_vpn_sg.id]
  private_ip             = "10.240.1.247"

  # 퍼블릭 IP 할당
  associate_public_ip_address = true

  # 키페어
  key_name = "awesomekey"

   # 리소스가 삭제되지 않도록 방지
  lifecycle {
    prevent_destroy = true   
  }

  tags = {
    Name = "vpn-gateway-instance"
  }
}


terraform {
  backend "local" {
    path = "C:/TF_On-premise/terraform.tfstate"
  }
}

output "onprem_vpn_eip_public_ip" {
  value = aws_eip.onprem_vpn_eip.public_ip
}

# Elastic IP 생성
resource "aws_eip" "onprem_vpn_eip" {
  vpc = true
  instance = aws_instance.vpn_gateway_instance.id  # EC2 인스턴스에 Elastic IP 연결

  # 리소스가 삭제되지 않도록 방지
  lifecycle {
    prevent_destroy = true   
  }


  tags = {
    Name = "onprem-vpn-eip"
  }
}
