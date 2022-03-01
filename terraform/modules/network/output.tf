
#############################
# Variables for outside use #
#############################

// private subnet group for database use
output "subnet_group_id" {
  value = aws_db_subnet_group.subnet_group_private.id
}



output "private_subnets" {
  value = [ aws_subnet.private_subnet_1,
            aws_subnet.private_subnet_2 ]
}

output "public_subnets" {
  value = [ aws_subnet.public_subnet_1,
            aws_subnet.public_subnet_2 ]
}

// vpc to use across the program
output "utopia_vpc" {
  value = aws_vpc.am-vpc-db.id
}
