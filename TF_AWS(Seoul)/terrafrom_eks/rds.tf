# PRD DB 서브넷 그룹
resource "aws_db_subnet_group" "prd_db_subnet" {
  name       = "prd_subnetgroup"
  subnet_ids = [aws_subnet.prd_db_sub_a.id, aws_subnet.prd_db_sub_c.id]

  tags = {
    Name = "prd_subnetgroup"
  }
}

# PRD DB 구성
resource "aws_db_instance" "prd_db" {
  identifier_prefix      = "prd-database"
  allocated_storage      = 20
  engine                 = "mariadb"
  engine_version         = "10.11.8"
  instance_class         = "db.t3.micro"
  db_name                = "prd"
  username               = "admin"
  password               = "password!"
  parameter_group_name   = "mariadb-parameter-group"
  skip_final_snapshot    = true
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.prd_db_subnet.name
  vpc_security_group_ids = [aws_security_group.prd_db_security.id]


  tags = {
    Name = "prd_db"
  }
}

# DEV DB 서브넷 그룹
resource "aws_db_subnet_group" "dev_db_subnet" {
  name       = "dev_subnetgroup"
  subnet_ids = [aws_subnet.dev_db_sub_a.id, aws_subnet.dev_db_sub_c.id]

  tags = {
    Name = "dev_subnetgroup"
  }
}

# DEV DB 구성
resource "aws_db_instance" "dev_db" {
  identifier_prefix      = "dev-database"
  allocated_storage      = 20
  engine                 = "mariadb"
  engine_version         = "10.11.8"
  instance_class         = "db.t3.micro"
  db_name                = "dev"
  username               = "admin"
  password               = "password!"
  parameter_group_name   = "mariadb-parameter-group"
  skip_final_snapshot    = true
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.dev_db_subnet.name
  vpc_security_group_ids = [aws_security_group.dev_db_security.id]


  tags = {
    Name = "dev_db"
  }
}