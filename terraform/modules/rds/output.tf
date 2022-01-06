
#############################
# Variables for outside use #
#############################

// subnet group for database use
output "subnet_group_id" {
  value = aws_db_instance.rds.endpoint
}
