# DMS 인스턴스를 위한 보안 그룹 (서울)
resource "aws_security_group" "prd_dms_sg" {
  name        = "prd-dms-sg"
  description = "Security group for PRD DMS Replication Instance"
  vpc_id      = aws_vpc.prd_vpc.id

  # Ingress: DMS 복제 인스턴스가 데이터베이스와 통신할 수 있도록 허용 (MySQL 예시)
  ingress {
    from_port   = 3306  # MySQL 포트 (다른 DB 엔진을 사용하면 해당 포트를 설정)
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.240.0.0/16"]  # PRD 대역
  }

  # Ingress: DMS 인스턴스와 VPN 간 통신을 허용 (필요 시 다른 포트 추가 가능)
  ingress {
    from_port   = 500
    to_port     = 500
    protocol    = "udp"
    cidr_blocks = ["10.240.0.0/16"]
  }

  ingress {
    from_port   = 4500
    to_port     = 4500
    protocol    = "udp"
    cidr_blocks = ["10.240.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.240.0.0/16"]
  }


  ingress {
    from_port   = -1           # ICMP 전체 허용 (ping 포함)
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.240.0.0/16"]  # on-premise VPC CIDR (피어링된 VPC로부터의 요청을 허용)
  }

  # Egress: 외부로 나가는 모든 트래픽을 허용 (필요시 제한 가능)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # 모든 프로토콜 허용
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "prd-dms-sg"
  }
}

# DMS VPC IAM 역할 생성
resource "aws_iam_role" "dms_vpc_role" {
  name = "dms-vpc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "dms.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "dms-vpc-role"
  }
}

# DMS VPC IAM 정책 생성 (모든 필요한 권한 포함)
resource "aws_iam_policy" "dms_vpc_policy" {
  name        = "dms-vpc-policy"
  description = "Policy for DMS VPC Access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeDBInstances",
          "ec2:DescribeVpcs",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:AttachNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:DescribeRouteTables",
          "ec2:DescribeNatGateways",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeAvailabilityZones",
          "dms:CreateReplicationInstance",     # DMS 복제 인스턴스 생성 권한
          "dms:CreateReplicationSubnetGroup",  # DMS 서브넷 그룹 생성 권한
          "dms:DescribeReplicationInstances",
          "dms:DescribeReplicationSubnetGroups",
          "dms:DeleteReplicationInstance",     # DMS 인스턴스 삭제 권한
          "dms:ModifyReplicationInstance",     # DMS 인스턴스 수정 권한
          "dms:DescribeReplicationTasks",      # DMS 태스크 설명 권한
          "dms:StartReplicationTask",          # DMS 태스크 시작 권한
          "dms:StopReplicationTask",           # DMS 태스크 중지 권한
          "dms:DescribeEndpoints",             # DMS 엔드포인트 설명 권한
          "dms:ModifyEndpoint",                # DMS 엔드포인트 수정 권한
          "dms:CreateEndpoint",                # DMS 엔드포인트 생성 권한
          "dms:DeleteEndpoint"                 # DMS 엔드포인트 삭제 권한
        ],
        Resource = "*"
      }
    ]
  })
}

# IAM 역할에 정책 연결
resource "aws_iam_role_policy_attachment" "dms_vpc_role_policy_attachment" {
  role       = aws_iam_role.dms_vpc_role.name
  policy_arn = aws_iam_policy.dms_vpc_policy.arn
}

# DMS 복제 인스턴스 (서울)
resource "aws_dms_replication_instance" "prd_dms_instance" {
  replication_instance_id     = "prd-dms-instance"
  replication_instance_class  = "dms.t2.micro"
  allocated_storage           = 100
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.prd_dms_sg.id, aws_security_group.prd_vpn_sg.id]
  availability_zone           = "ap-northeast-2a"
  replication_subnet_group_id = aws_dms_replication_subnet_group.prd_dms_subnet_group.id

  depends_on = [aws_iam_role_policy_attachment.dms_vpc_role_policy_attachment]  # 의존성 추가

  tags = {
    Name = "prd-dms-replication-instance"
  }
}


# DMS 서브넷 그룹 생성
resource "aws_dms_replication_subnet_group" "prd_dms_subnet_group" {
  replication_subnet_group_id = "prd-dms-subnet-group"
  replication_subnet_group_description = "Subnet group for PRD DMS replication"
  subnet_ids                  = [aws_subnet.prd_pub_sub_a.id, aws_subnet.prd_pub_sub_c.id]

  tags = {
    Name = "prd-dms-subnet-group"
  }
}

