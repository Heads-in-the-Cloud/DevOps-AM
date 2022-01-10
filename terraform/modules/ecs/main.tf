
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "am_ecs_cluster"
}

resource "aws_ecs_task_definition" "api_flights" {
  // general
  family = "service"
  requires_compatibilities = ["FARGATE"]

  // variable
  task_role_arn = var.task_arn
  execution_role_arn = var.task_arn
  network_mode = var.net_mode
  memory = var.memory
  cpu = var.cpu

  // containers
  container_definitions = jsonencode([
    {
      name = "am-task-flights"
      image = var.flights-repo
      memory = var.memory
      cpu = var.cpu
      portMappings = [
        {
          containerPort = 8081
          hostPort = 8081
        }]
      environment = var.environment
    }
  ])

  tags = {
    Name = "am-task-flights"
  }
}
