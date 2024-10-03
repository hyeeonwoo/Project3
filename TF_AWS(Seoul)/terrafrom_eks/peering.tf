# VPC Peering
resource "aws_vpc_peering_connection" "prd_dev_peer" {
  vpc_id        = aws_vpc.prd_vpc.id
  peer_vpc_id   = aws_vpc.dev_vpc.id
  auto_accept   = true

  tags = {
    Name = "prd-dev-peering"
  }
}
