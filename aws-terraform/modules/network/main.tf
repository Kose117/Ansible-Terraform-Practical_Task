resource "aws_vpc" "lab" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(var.tags, { Name = "ansible-lab-vpc" })
}

resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id
  tags = merge(var.tags, { Name = "ansible-lab-igw" })
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az
  tags = merge(var.tags, { Name = "ansible-lab-public-a" })
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab.id
  }
  tags = merge(var.tags, { Name = "ansible-lab-rt-public" })
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.lab.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = false
  availability_zone       = var.az
  tags = merge(var.tags, { Name = "ansible-lab-private-a" })
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(var.tags, { Name = "ansible-lab-nat-eip" })
}

resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public_a.id
  allocation_id = aws_eip.nat.id
  tags = merge(var.tags, { Name = "ansible-lab-nat" })
  depends_on = [aws_internet_gateway.lab]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(var.tags, { Name = "ansible-lab-rt-private" })
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "sg_control" {
  name        = "ansible-lab-sg-control"
  description = "SSH from anywhere to control (lab environment); egress all"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description = "SSH from anywhere (lab environment)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "ansible-lab-sg-control" })
}

resource "aws_security_group" "sg_nodes" {
  name        = "ansible-lab-sg-nodes"
  description = "Allow SSH only from control; egress all"
  vpc_id      = aws_vpc.lab.id

  ingress {
    description     = "SSH from control SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.sg_control.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "ansible-lab-sg-nodes" })
}