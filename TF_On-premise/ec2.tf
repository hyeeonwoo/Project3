# Key (ssh-keygen -m PEM -f awesomekey)
resource "aws_key_pair" "key" {
  key_name   = "awesomekey"
  public_key = file("awesomekey.pub")
}


# Bastion 인스턴스 (퍼블릭 서브넷)
resource "aws_instance" "onprem_bastion" {
  ami                    = data.aws_ami.ubuntu_20_04.id
  instance_type          = "t2.micro"
  key_name               = "awesomekey"
  subnet_id              = aws_subnet.onprem_public.id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  # 리소스가 삭제되지 않도록 방지
  lifecycle {
    prevent_destroy = true   
  }

  # 고정된 퍼블릭 IP 할당
  associate_public_ip_address = true
  # 고정된 프라이빗 IP 할당
  private_ip = "10.240.1.240"  # 미리 지정한 프라이빗 IP

  tags = {
    Name = "onprem_bastion"
  }
}

# 로드밸런서 (프라이빗 서브넷에 고정 IP 할당)
resource "aws_instance" "onprem_lb1" {
  ami                    = data.aws_ami.ubuntu_20_04.id
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.onprem_public.id
  key_name               = "awesomekey"
  vpc_security_group_ids = [aws_security_group.internal_sg.id]

  # 리소스가 삭제되지 않도록 방지
  lifecycle {
    prevent_destroy = true   
  }

  private_ip = "10.240.1.238"  # 고정된 프라이빗 IP

  tags = {
    Name = "onprem_lb"
  }
}

resource "aws_instance" "onprem_lb2" {
  ami                    = data.aws_ami.ubuntu_20_04.id
  instance_type          = "t2.medium"
  subnet_id              = aws_subnet.onprem_public.id
  key_name               = "awesomekey"
  vpc_security_group_ids = [aws_security_group.internal_sg.id]

  # 리소스가 삭제되지 않도록 방지
  lifecycle {
    prevent_destroy = true   
  }

  private_ip = "10.240.1.239"  # 고정된 프라이빗 IP

  tags = {
    Name = "onprem_lb"
  }
}

# 마스터 노드 3대
resource "aws_instance" "onprem_master" {
  count         = 3
  ami           = data.aws_ami.ubuntu_20_04.id
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.onprem_public.id
  key_name      = "awesomekey"
  vpc_security_group_ids = [aws_security_group.internal_sg.id]

  # 리소스가 삭제되지 않도록 방지
  lifecycle {
    prevent_destroy = true   
  }

  private_ip = element(["10.240.1.241", "10.240.1.242", "10.240.1.243"], count.index)

  tags = {
    Name = "onprem_master_${count.index + 1}"
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io kubeadm kubelet kubectl
    kubeadm init --control-plane-endpoint "10.240.1.240:6443" --pod-network-cidr=10.244.0.0/16
    # kubeadm init이 완료된 후 admin.conf를 복사하여 접근 가능하게 설정
    mkdir -p $HOME/.kube
    cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    chown $(id -u):$(id -g) $HOME/.kube/config
  EOF

}

# 워커 노드 3대
resource "aws_instance" "onprem_worker" {
  count         = 3
  ami           = data.aws_ami.ubuntu_20_04.id
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.onprem_public.id
  key_name      = "awesomekey"
  vpc_security_group_ids = [aws_security_group.internal_sg.id]

  # 리소스가 삭제되지 않도록 방지
  lifecycle {
    prevent_destroy = true   
  }

  private_ip = element(["10.240.1.244", "10.240.1.245", "10.240.1.246"], count.index)

  tags = {
    Name = "onprem_worker_${count.index + 1}"
  }

  user_data = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io kubeadm kubelet kubectl
    kubeadm join 10.240.1.241:6443 --token <TOKEN> --discovery-token-ca-cert-hash <CA_CERT_HASH>
  EOF

}

# AMI Data Source for Ubuntu 20.04 (대체 Ubuntu 24.04)
data "aws_ami" "ubuntu_20_04" {
  most_recent = true
  owners      = ["099720109477"]  # Ubuntu 공식 AMI 계정 ID
  name_regex  = "^ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}