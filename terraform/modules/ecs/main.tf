
#################
# ECS Resources #
#################

// load balancing
resource "aws_lb" "utopia_nwb" {
  name               = "${var.environment_name}-alb-utopia"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.service_subnets
  security_groups    = [var.loadbalancer_sg]
}

// route 53
resource "aws_route53_record" "utopia_record" {
  zone_id = var.r53_zone_id
  name    = var.record_name
  type    = "CNAME"
  ttl     = "60"
  records = [aws_lb.utopia_nwb.dns_name]
}
