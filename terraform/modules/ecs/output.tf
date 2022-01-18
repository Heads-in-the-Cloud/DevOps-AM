
output "ALB_ID" {
  value = aws_alb.utopia_alb.id
}

output "ECS_CLUSTER" {
  value = aws_ecs_cluster.ecs_cluster.id
}
