# PRD용 vpn 보안 그룹 생성
resource "aws_security_group" "prd_vpn_sg" {
  name        = "prd-vpn-sg"
  description = "Security group for PRD VPN"
  vpc_id      = aws_vpc.prd_vpc.id

  ingress {
    from_port   = 50
    to_port     = 50
    protocol    = "50"  # ESP 프로토콜 (IP 프로토콜 번호 50)
    cidr_blocks = ["10.240.0.0/16"]  # 상대 리전의 VPC CIDR
  }
  
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["10.240.0.0/16"]  # PRD 대역
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["10.240.0.0/16"]  # PRD 대역
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # PRD 대역
  }

  ingress {
   from_port   = -1
   to_port     = -1
   protocol    = "icmp"
   cidr_blocks = ["10.240.0.0/16"]  # 상대 리전의 VPC CIDR
 }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["10.240.0.0/16"]  # 버지니아 리전 VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # 모든 트래픽 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prd-vpn-sg"
  }
}

# 가상 프라이빗 게이트웨이 (서울)
resource "aws_vpn_gateway" "prd_vpn_gw" {
  vpc_id = aws_vpc.prd_vpc.id


  tags = {
    Name = "prd-vpn-gw"
  }
}

# 버지니아 리전의 Terraform 상태 참조
data "terraform_remote_state" "virginia" {
  backend = "local"

  config = {
    path = "C:/TF_On-premise/terraform.tfstate"  # 로컬 경로 참조
  }
}

# 고객 게이트웨이에 퍼블릭 IP 사용 (Elastic IP)
resource "aws_customer_gateway" "prd_vpn_cgw" {
  bgp_asn    = 65000
  ip_address = data.terraform_remote_state.virginia.outputs.onprem_vpn_eip_public_ip  # 버지니아 Elastic IP를 사용
  type       = "ipsec.1"


  tags = {
    Name = "prd-vpn-cgw"
  }
}



# VPN 연결 (서울 → 버지니아)
resource "aws_vpn_connection" "prd_to_virginia_vpn" {
  customer_gateway_id = aws_customer_gateway.prd_vpn_cgw.id
  vpn_gateway_id      = aws_vpn_gateway.prd_vpn_gw.id
  type                = "ipsec.1"

  # 정적 라우팅 사용
  static_routes_only  = true

  local_ipv4_network_cidr = "10.240.0.0/16"
  remote_ipv4_network_cidr = aws_vpc.prd_vpc.cidr_block

  tags = {
    Name = "prd-vpn-connection"
  }
}


# VPN 연결 라우트 (정적 라우팅 사용)
resource "aws_vpn_connection_route" "prd_vpn_route" {
  vpn_connection_id = aws_vpn_connection.prd_to_virginia_vpn.id
  destination_cidr_block = "10.240.0.0/16"


}

