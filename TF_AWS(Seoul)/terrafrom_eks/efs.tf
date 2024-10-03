# EFS 파일 시스템 생성
resource "aws_efs_file_system" "example" {
  creation_token   = "my-efs-unique-token"
  performance_mode = "generalPurpose"

  tags = {
    Name = "my-efs-sooo"  # 원하는 EFS 이름
  }
}

# EFS 마운트 대상 생성 (2a 가용 영역)
resource "aws_efs_mount_target" "example_a" {
  file_system_id = aws_efs_file_system.example.id
  subnet_id      = aws_subnet.prd_node_sub_a.id  # EFS를 마운트할 2a 서브넷 ID
}

# EFS 마운트 대상 생성 (2c 가용 영역)
resource "aws_efs_mount_target" "example_c" {
  file_system_id = aws_efs_file_system.example.id
  subnet_id      = aws_subnet.prd_node_sub_c.id  # EFS를 마운트할 2c 서브넷 ID
}

# 기존 EC2 인스턴스 참조
data "aws_instance" "efs_managed_server" {
  instance_id = aws_instance.prd_efs_managed_Server.id # 기존 EC2 인스턴스의 ID
}
