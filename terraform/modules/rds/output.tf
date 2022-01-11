
#############################
# Variables for outside use #
#############################

// subnet group for database use
output "db_address" {
  value = aws_db_instance.rds.endpoint
}

output "bastion_public_id" {
  value = aws_instance.bastion.public_ip
}
