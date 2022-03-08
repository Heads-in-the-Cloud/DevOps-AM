
################
# Bastion Host #
################

resource "aws_security_group" "bastion_security" {
  name        = "${var.environment_name}-bastion-security"
  description = "Allow SSH globally"
  vpc_id      = var.vpc_id

  # Public Bastion SSH Access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Bastion Internet Access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-bastion-security"
  }
}

################
# RDS Instance #
################

resource "aws_security_group" "db_security" {
  name        = "${var.environment_name}-rds-security"
  description = "Allow SQL specific traffic from VPC subnets"
  vpc_id      = var.vpc_id

  # DB Access from Subnets
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = concat(var.public_cidrs, var.private_cidrs)
  }

  tags = {
    Name = "${var.environment_name}-rds-security"
  }
}

###############
# ECS Cluster #
###############

resource "aws_security_group" "ecs_api_access" {
  name        = "${var.environment_name}-ecs-allow-traffic"
  description = "Open API Ports to NWB"
  vpc_id      = var.vpc_id

  # General API ports from LB
  ingress {
    from_port   = 8081
    to_port     = 8083
    protocol    = "tcp"
    cidr_blocks = var.public_cidrs
  }

  # Auth API port from LB
  ingress {
    from_port   = 8443
    to_port     = 8443
    protocol    = "tcp"
    cidr_blocks = var.public_cidrs
  }

  # API Internet Access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-ecs-allow-traffic"
  }
}

###############
# EKS Cluster #
###############

resource "aws_security_group" "eks_api_access" {
  name        = "${var.environment_name}-eks-allow-traffic"
  description = "Open HTTP to Ingress LoadBalancer and allow Egress"
  vpc_id      = var.vpc_id

  # HTTP from all sources
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.public_cidrs
  }

  # API Internet Access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-eks-allow-traffic"
  }
}

####################
# ECS LoadBalancer #
####################

resource "aws_security_group" "ecs_loadbalancer_access" {
  name        = "${var.environment_name}-ecs-lb-all-traffic"
  description = "Open HTTP Listeners to Global"
  vpc_id      = var.vpc_id

  # HTTP from all sources
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "http"
    cidr_blocks = var.public_cidrs
  }

  # API Internet Access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment_name}-ecs-lb-all-traffic"
  }
}
