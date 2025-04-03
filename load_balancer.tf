# load_balancer.tf
resource "aws_lb" "app_lb" {
  count              = var.vpc_count
  name               = "app-lb-${var.vpc_name}-${count.index}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg[count.index].id]
  subnets            = [for i in range(length(var.availability_zones)) : aws_subnet.public_subnets[count.index * length(var.availability_zones) + i].id]

  enable_deletion_protection = false

  tags = {
    Name = "ALB-${var.vpc_name}-${count.index}"
  }
}

resource "aws_lb_target_group" "app_tg" {
  count       = var.vpc_count
  name        = "app-tg-${var.vpc_name}-${count.index}"
  port        = var.application_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.my_vpc[count.index].id
  target_type = "instance"

  health_check {
    enabled             = true
    interval            = var.healthcheck_interval
    path                = var.health_check_path
    port                = "traffic-port"
    healthy_threshold   = var.healthy_threshold
    unhealthy_threshold = var.unhealthy_threshold
    timeout             = var.healthcheck_timeout
    protocol            = "HTTP"
    matcher             = "200"
  }

  tags = {
    Name = "TG-${var.vpc_name}-${count.index}"
  }
}

resource "aws_lb_listener" "http" {
  count             = var.vpc_count
  load_balancer_arn = aws_lb.app_lb[count.index].arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg[count.index].arn
  }
}