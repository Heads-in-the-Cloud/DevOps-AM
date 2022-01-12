
#################
# ECS Task Info #
#################

resource "aws_ecs_task_definition" "api_tasks" {
  // general
  for_each = local.indexes
  family = "AM-task-${each.key}"
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
      name = "AM-task-${each.key}"
      image = local.repos[each.key]
      memory = var.memory
      cpu = var.cpu
      essential = true
      portMappings = [
        {
          containerPort = each.value
          hostPort = each.value
        }]
      environment = var.environment
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = "/ecs/AM-ecs-apis"
          awslogs-region = "us-west-2"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "api_services" {
  for_each = local.indexes
  name = "AM-${each.key}-service"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.api_tasks[each.key].arn
  desired_count = var.desired-container-count
  launch_type = "FARGATE"
  network_configuration {
    security_groups = [ aws_security_group.ecs_api_security.id ]
    subnets = var.service_subnets
    assign_public_ip = true
  }
  load_balancer {
    container_name = "AM-task-${each.key}"
    container_port = each.value
    target_group_arn = aws_lb_target_group.flights_direct[each.key].arn
  }
}
