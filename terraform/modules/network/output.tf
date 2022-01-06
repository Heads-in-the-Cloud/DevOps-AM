
output "subnet_group_id" {
  value = aws_db_subnet_group.subnet_group_private.id
}

output "public_subnet_id_1" {
  value = aws_subnet.public_subnet_1.id
}

output "db_vpc" {
  value = aws_vpc.am-vpc-db.id
}
