
resource "aws_vpc" "am-vpc-db" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true
  tags = {
    Name = "am-vpc-db"
  }
}

resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.am-vpc-db.id
  cidr_block = var.vpc_subnet_1_private_cidr
  availability_zone = var.zone_1
  tags = {
    Name = "am-subnet-private-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.am-vpc-db.id
  cidr_block = var.vpc_subnet_2_private_cidr
  availability_zone = var.zone_2
  tags = {
    Name = "am-subnet-private-2"
  }
}

resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.am-vpc-db.id
  cidr_block = var.vpc_subnet_1_public_cidr
  availability_zone = var.zone_1
  tags = {
    Name = "am-subnet-public-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.am-vpc-db.id
  cidr_block = var.vpc_subnet_2_public_cidr
  availability_zone = var.zone_2
  tags = {
    Name = "am-subnet-public-2"
  }
}

resource "aws_internet_gateway" "vpc_gateway" {
  vpc_id = aws_vpc.am-vpc-db.id
  tags = {
    Name = "am-vpc-gateway"
  }
}

//resource "aws_route_table" "vpc_route_table" {
//  vpc_id = aws_vpc.am-vpc-db.id
//  route {
//    cidr_block = var.route_cidr
//  }
//  tags = {
//    Name = "am-vpc-route-table"
//  }
//}
//
//resource "aws_route" "vpc-route-db" {
//  route_table_id = aws_route_table.vpc_route_table.id
//  destination_cidr_block = var.vpc_cidr
//}
//
//resource "aws_route_table_association" "route_private_subnet_1" {
//  subnet_id = aws_subnet.private_subnet_1.id
//  route_table_id = aws_route_table.vpc_route_table.id
//}
//
//resource "aws_route_table_association" "route_private_subnet_2" {
//  subnet_id = aws_subnet.private_subnet_2.id
//  route_table_id = aws_route_table.vpc_route_table.id
//}
//
//resource "aws_route_table_association" "route_public_subnet_1" {
//  subnet_id = aws_subnet.public_subnet_1.id
//  route_table_id = aws_route_table.vpc_route_table.id
//}
//
//resource "aws_route_table_association" "route_public_subnet_2" {
//  subnet_id = aws_subnet.public_subnet_2.id
//  route_table_id = aws_route_table.vpc_route_table.id
//}

resource "aws_db_subnet_group" "subnet_group_private" {
  name = "subnet_group_private"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  tags = {
    Name = "am-db-private-subnet-group"
  }
}
