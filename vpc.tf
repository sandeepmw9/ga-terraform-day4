data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

resource "aws_vpc" "lab4_vpc" {
  cidr_block = var.cidr
  tags = {
    Name      = "${var.vpc_name}-${random_string.suffix.id}-${terraform.workspace}"
    terraform = true
  }
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.lab4_vpc.id
  cidr_block        = cidrsubnet(var.cidr, 8, 1)
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    terraform = true
  }

}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.lab4_vpc.id
  cidr_block        = cidrsubnet(var.cidr, 8, 2)
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    terraform = true
  }
}
resource "aws_internet_gateway" "lab4_igw" {
  vpc_id = aws_vpc.lab4_vpc.id

  tags = {
    terraform = true
  }
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.lab4_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.lab4_igw.id
  }

  tags = {
    terraform = true
  }
}

resource "aws_route_table_association" "public" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public.id
}


resource "aws_security_group" "lab4_sg" {
  vpc_id = aws_vpc.lab4_vpc.id
  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = ingress.value.name
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  egress {
    description = "Allow all ip and ports outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

