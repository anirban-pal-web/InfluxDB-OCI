resource "aws_lb" "alb" {
  name               = "influxdb-alb"
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.subnets
}

resource "aws_lb_target_group" "primary" {
  name     = "tg-primary"
  port     = 8086
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_target_group" "dr" {
  name     = "tg-dr"
  port     = 8086
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 8086
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.primary.arn
  }
}

resource "aws_lb_target_group_attachment" "primary_attach" {
  target_group_arn = aws_lb_target_group.primary.arn
  target_id        = var.primary_instance_id
  port             = 8086
}

resource "aws_lb_target_group_attachment" "dr_attach" {
  target_group_arn = aws_lb_target_group.dr.arn
  target_id        = var.dr_instance_id
  port             = 8086
}

