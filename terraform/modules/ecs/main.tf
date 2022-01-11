
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "am_ecs_cluster"
}

resource "aws_ecs_task_definition" "api_flights" {
  // general
  family = local.flights_name
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
      name = local.flights_name
      image = var.flights-repo
      memory = var.memory
      cpu = var.cpu
      essential = true
      portMappings = [
        {
          containerPort = 8081
          hostPort = 8081
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

resource "aws_ecs_service" "flights_service" {
  name = "AM-flights-service"
  cluster = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.api_flights.arn
  desired_count = 1
  launch_type = "FARGATE"
  network_configuration {
    security_groups = [ aws_security_group.ecs_api_security.id ]
    subnets = var.service_subnets
    assign_public_ip = false
  }
//  load_balancer {
//    container_name = local.flights_name
//    container_port = 8081
//    target_group_arn = ""
//  }
}

//resource "aws_lb_target_group" "flights_direct" {
//  name = "AM-ecs-flights-target"
//  port = 8081
//  protocol = "TCP"
//  target_type = "ip"
//  vpc_id = var.vpc_id
//}

resource "aws_security_group" "ecs_api_security" {
  name = "AM-allow-apis"
  description = "Open SSH and all API ports"
  vpc_id = var.vpc_id

  # SSH port
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Data API ports
  ingress {
    from_port   = 8080
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Auth API port
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outgoing coverage
  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AM-allow-apis"
  }
}
