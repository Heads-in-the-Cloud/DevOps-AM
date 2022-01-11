
#############################
# Variables for outside use #
#############################

// subnet group for database use
output "subnet_group_id" {
  value = aws_db_subnet_group.subnet_group_private.id
}

output "all_subnets" {
  value = [ aws_subnet.private_subnet_1.id,
            aws_subnet.private_subnet_2.id,
            aws_subnet.public_subnet_1.id,
            aws_subnet.public_subnet_2.id ]
}

output "db_vpc" {
  value = aws_vpc.am-vpc-db.id
}
