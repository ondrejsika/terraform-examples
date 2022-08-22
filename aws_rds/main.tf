resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.example.id
}

resource "aws_route_table" "example" {
  vpc_id = aws_vpc.example.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.example.id
  }
}

resource "aws_subnet" "example-rds-a" {
  availability_zone       = "eu-central-1a"
  cidr_block              = "10.0.1.0/24"
  vpc_id                  = aws_vpc.example.id
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "example-rds-a" {
  subnet_id      = aws_subnet.example-rds-a.id
  route_table_id = aws_route_table.example.id
}

resource "aws_subnet" "example-rds-b" {
  availability_zone       = "eu-central-1b"
  cidr_block              = "10.0.2.0/24"
  vpc_id                  = aws_vpc.example.id
  map_public_ip_on_launch = true
}

resource "aws_route_table_association" "example-rds-b" {
  subnet_id      = aws_subnet.example-rds-b.id
  route_table_id = aws_route_table.example.id
}

resource "aws_db_subnet_group" "example-rds" {
  name = "example-rds"
  subnet_ids = [
    aws_subnet.example-rds-a.id,
    aws_subnet.example-rds-b.id,
  ]
}

resource "random_password" "rds-example" {
  length           = 16
  special          = true
  override_special = "_"
}

resource "aws_security_group" "example-allow-all" {
  name        = "example-allow-all"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.example.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_db_instance" "example" {
  identifier        = "example"
  allocated_storage = 5
  engine            = "mysql"
  engine_version    = "5.7"
  instance_class    = "db.t3.micro"
  db_name           = "example"
  username          = "admin"
  password          = random_password.rds-example.result
  depends_on = [
    aws_security_group.example-allow-all,
  ]
  vpc_security_group_ids = [
    aws_security_group.example-allow-all.id
  ]
  db_subnet_group_name = aws_db_subnet_group.example-rds.id
  publicly_accessible  = true
  skip_final_snapshot  = false
}

output "host" {
  value = aws_db_instance.example.address
}

output "port" {
  value = aws_db_instance.example.port
}

output "user" {
  value = aws_db_instance.example.username
}

output "password" {
  value     = aws_db_instance.example.password
  sensitive = true
}

output "uri" {
  value     = "mysql://${aws_db_instance.example.username}:${aws_db_instance.example.password}@${aws_db_instance.example.address}:${aws_db_instance.example.port}/${aws_db_instance.example.db_name}"
  sensitive = true
}
