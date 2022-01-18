
###############
# ALB Hookups #
###############

//resource "aws_lb_target_group" "flights_direct" {
//  for_each = local.indexes
//  name = "AM-ecs-${each.value}-target"
//  port = each.value
//  protocol = "HTTP"
//  target_type = "ip"
//  vpc_id = var.vpc_id
//}
//
//resource "aws_alb_listener" "flights_listener" {
//  for_each = local.indexes
//  load_balancer_arn = aws_alb.utopia_alb.arn
//  port = each.value
//  protocol = "HTTP"
//  default_action {
//    type = "forward"
//    target_group_arn = aws_lb_target_group.flights_direct[each.key].arn
//  }
//}
