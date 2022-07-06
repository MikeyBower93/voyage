resource "aws_security_group" "lb_security_group" {
  name        = "${var.service_name}_lb_security_group"
  description = "Allow all outbound traffic and https inbound"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = "${var.service_name}-tg"
  port        = 4000
  protocol    = "HTTP"
  vpc_id      = aws_default_vpc.default_vpc.id
  target_type = "ip"
  health_check {
    path = "/health"
    port = "4000"
  }
  stickiness {
    type            = "lb_cookie"
    enabled         = "true"
    cookie_duration = "3600"
  }
}

resource "aws_lb" "load_balancer" {
  name               = "${var.service_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_security_group.id]
  subnets            = data.aws_subnet_ids.vpc.ids

  enable_deletion_protection = false
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}
