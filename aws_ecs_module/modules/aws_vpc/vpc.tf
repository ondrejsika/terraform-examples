variable "name" {}
variable "cidr_block" {}
variable "subnets" {}

resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = {
    "Name" = var.name
  }
}

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.key
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }
}

resource "aws_route_table_association" "this" {
  for_each = aws_subnet.this

  subnet_id      = each.value.id
  route_table_id = aws_route_table.this.id
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "subnet_ids" {
  value = [for k, v in aws_subnet.this : v.id]
}
