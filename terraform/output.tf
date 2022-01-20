
output "AWS_VPC_ID" {
  value = module.network.utopia_vpc
}

output "AWS_RDS_ENDPOINT" {
  value = module.utopia-db.db_address
}

output "AWS_ALB_ID" {
  value = module.ecs.ALB_ID
}

output "SUBNET_ECS_1" {
  value = module.network.all_subnets[2]
}

output "SUBNET_ECS_2" {
  value = module.network.all_subnets[3]
}

output "ECS_SECURITY_GROUP" {
  value = module.ecs.SECURITY_GR
}
