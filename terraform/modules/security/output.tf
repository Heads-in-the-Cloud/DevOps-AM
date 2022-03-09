
output "SG_Bastion" {
  value = aws_security_group.bastion_security.id
}

output "SG_RDS" {
  value = aws_security_group.db_security.id
}

output "SG_ECS" {
  value = aws_security_group.ecs_api_access.id
}

output "SG_EKS" {
  value = aws_security_group.eks_api_access.id
}

output "SG_ECS_LB" {
  value = aws_security_group.ecs_loadbalancer_access.id
}
