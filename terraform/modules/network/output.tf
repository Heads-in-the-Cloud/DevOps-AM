
#############################
# Variables for outside use #
#############################

// Private subnet group ID for database use
output "subnet_group_id" {
  value = aws_db_subnet_group.subnet_group_private.id
}

// List of private subnets for passing
output "private_subnets" {
  value = [ aws_subnet.private_subnet_1.id,
            aws_subnet.private_subnet_2.id ]
}

// List of public subnets for passing
output "public_subnets" {
  value = [ aws_subnet.public_subnet_1.id,
            aws_subnet.public_subnet_2.id ]
}

// VPC ID to use across the program
output "utopia_vpc" {
  value = aws_vpc.am-vpc-db.id
}
