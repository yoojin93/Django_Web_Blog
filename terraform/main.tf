# create vpc
resource "aws_vpc" "djangoblog_vpc" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "djangoblog_vpc"
  }
}

# create public web subnets
resource "aws_subnet" "public_web_subnet" {
  count = length(var.public_web_subnet_cidr_blocks)

  cidr_block = var.public_web_subnet_cidr_blocks[count.index]
  vpc_id     = aws_vpc.djangoblog_vpc.id

  tags = {
    Name = "djangoblog_public_web_subnet_${count.index + 1}"
  }
}

# create private application subnets with django ec2 web app
resource "aws_subnet" "private_app_subnet" {
  count = length(var.private_app_subnet_cidr_blocks)

  cidr_block = var.private_app_subnet_cidr_blocks[count.index]
  vpc_id     = aws_vpc.djangoblog_vpc.id

  tags = {
    Name = "djangoblog_private_app_subnet_${count.index + 1}"
  }
}

# create private database subnets with rds in it
resource "aws_subnet" "private_db_subnet" {
  count = length(var.private_db_subnet_cidr_blocks)

  cidr_block = var.private_db_subnet_cidr_blocks[count.index]
  vpc_id     = aws_vpc.djangoblog_vpc.id

  tags = {
    Name = "djangoblog_private_db_subnet_${count.index + 1}"
  }
}

# create internet gateway
resource "aws_internet_gateway" "djangoblog_igw" {
  vpc_id = aws_vpc.djangoblog_vpc.id
}

# create route tables
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.djangoblog_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.djangoblog_igw.id
  }

  tags = {
    Name = "djangoblog_public_rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.djangoblog_vpc.id

  tags = {
    Name = "djangoblog_private_rt"
  }
}

# subnet association with route tables
resource "aws_route_table_association" "public_subnet_association" {
  count          = length(var.public_subnet_cidr_block)
  subnet_id      = aws_subnet.public_web_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_app_subnet_association" {
  count          = length(var.private_app_subnet_cidr_block)
  subnet_id      = aws_subnet.private_app_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_db_subnet_association" {
  count          = length(var.private_db_subnet_cidr_block)
  subnet_id      = aws_subnet.private_db_subnet.id
  route_table_id = aws_route_table.private_rt.id
}