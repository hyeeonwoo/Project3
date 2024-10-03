# prd redis 보안 그룹 생성 (Redis에 대한 접근 제어)
resource "aws_security_group" "prd_redis_sg" {
  name        = "prd_redis_sg"
  description = "Allow access to Redis"
  vpc_id      = aws_vpc.prd_vpc.id

  ingress {
    from_port   = 6379# Redis 기본 포트
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]# 필요에 맞게 조정 (특정 IP로 제한하는 것이 좋음)
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
    Name = "prd_redis_sg"
  }
}

# prd ElastiCache Redis 클러스터 생성
resource "aws_elasticache_replication_group" "prd_redis" {
  replication_group_id = "prd-redis-cluster"
  description          = "Redis replication group for prd environment"  # 변경됨
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_clusters   = 1  # Redis 클러스터 노드 수 설정
  port                 = 6379
  automatic_failover_enabled = false  # 단일 노드인 경우 false
  subnet_group_name    = aws_elasticache_subnet_group.prd_redis_subnet_group.name
  security_group_ids   = [aws_security_group.prd_redis_sg.id]

  tags = {
    Name = "prd_redis_cluster"
  }
}

# prd ElastiCache 서브넷 그룹 생성
resource "aws_elasticache_subnet_group" "prd_redis_subnet_group" {
  name       = "prd-redis-subnet-group"
  subnet_ids = [aws_subnet.prd_redis_sub_2a.id, aws_subnet.prd_redis_sub_2c.id]
  description = "prd Subnet group for Redis"
}

# dev redis 보안 그룹 생성 (Redis에 대한 접근 제어)
resource "aws_security_group" "dev_redis_sg" {
  name        = "dev_redis_sg"
  description = "Allow access to Redis"
  vpc_id      = aws_vpc.dev_vpc.id

  ingress {
    from_port   = 6379# Redis 기본 포트
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]# 필요에 맞게 조정 (특정 IP로 제한하는 것이 좋음)
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
    Name = "dev_redis_sg"
  }
}

# dev ElastiCache Redis 클러스터 생성
resource "aws_elasticache_replication_group" "dev_redis" {
  replication_group_id = "dev-redis-cluster"
  description          = "Redis replication group for dev environment"  # 변경됨
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_clusters   = 1  # Redis 클러스터 노드 수 설정
  port                 = 6379
  automatic_failover_enabled = false  # 단일 노드인 경우 false
  subnet_group_name    = aws_elasticache_subnet_group.dev_redis_subnet_group.name
  security_group_ids   = [aws_security_group.dev_redis_sg.id]

  tags = {
    Name = "dev_redis_cluster"
  }
}

# dev ElastiCache 서브넷 그룹 생성
resource "aws_elasticache_subnet_group" "dev_redis_subnet_group" {
  name       = "dev-redis-subnet-group"
  subnet_ids = [aws_subnet.dev_redis_sub_2a.id, aws_subnet.dev_redis_sub_2c.id]
  description = "dev Subnet group for Redis"
}