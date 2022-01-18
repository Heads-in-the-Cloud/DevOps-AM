
output "AWS_VPC_ID" {
  value = module.network.utopia_vpc
}

output "AWS_RDS_ENDPOINT" {
  value = module.utopia-db.db_address
}

output "AWS_RDS_USERNAME" {
  value = local.db_creds.DB_USERNAME
}

output "AWS_RDS_PASSWORD" {
  value = local.db_creds.DB_PASSWORD
}
