
output "ALB_ID" {
  value = aws_lb.utopia_nwb.id
}

output "ECS_CLUSTER" {
  value = aws_ecs_cluster.ecs_cluster.id
}
