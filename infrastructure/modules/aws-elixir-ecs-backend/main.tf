# --- Locate the default VPC
resource "aws_default_vpc" "default_vpc" {
  tags = {
    Name = "Default VPC"
  }
}

# --- Set up the ECS cluster and roles for all backend services
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs_cluster"
}

# Roles and permissions for the ECS service
resource "aws_iam_role" "ecs_role" {
  name               = "${var.service_name}_ecs_role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_role" "ecs_execution_role" {
  name               = "${var.service_name}_ecs_execution_role"
  assume_role_policy = <<-EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "",
        "Effect": "Allow",
        "Principal": {
          "Service": "ecs-tasks.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

resource "aws_iam_policy" "ecs_policy" {
  name   = "${var.service_name}_ecs_policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "ecr:GetAuthorizationToken",
              "ecr:BatchCheckLayerAvailability",
              "ecr:GetDownloadUrlForLayer",
              "ecr:BatchGetImage",
              "logs:CreateLogStream",
              "logs:PutLogEvents"
          ],
          "Resource": "*"
      }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "attach_ecs_policy" {
  name       = "${var.service_name}_attach-ecs-policy"
  roles      = [aws_iam_role.ecs_execution_role.name]
  policy_arn = aws_iam_policy.ecs_policy.arn
}

#--- Create the ECR repository for the docker images 
resource "aws_ecr_repository" "repo" {
  name                 = "${var.service_name}-repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

#--- Create load balancer for inbound public traffic
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

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.service_name}"
}

# --- ECS task definitions
resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.service_name}_task"
  task_role_arn            = aws_iam_role.ecs_role.arn
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  requires_compatibilities = ["FARGATE"]
  memory                   = 8192
  cpu                      = 4096

  network_mode = "awsvpc"

  container_definitions = <<-EOF
  [
    {
      "cpu": 0,
      "image": "${aws_ecr_repository.repo.repository_url}:latest",
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "${aws_cloudwatch_log_group.log_group.name}",
          "awslogs-region": "eu-west-2",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "portMappings": [
        {
          "hostPort": 4000,
          "protocol": "tcp",
          "containerPort": 4000
        }
      ],
      "environment": [],
      "mountPoints": [],
      "volumesFrom": [],
      "essential": true,
      "links": [],
      "name": "${var.service_name}"
    }
  ]
  EOF
}

# --- ECS services
resource "aws_ecs_service" "service" {
  name            = "${var.service_name}_service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = "${var.service_name}_task"

  desired_count = 2
  launch_type   = "FARGATE"
  network_configuration {
    security_groups  = [aws_security_group.security_group.id]
    subnets          = data.aws_subnet_ids.vpc.ids
    assign_public_ip = true
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = var.service_name
    container_port   = "4000"
  }
  service_registries {
    registry_arn   = aws_service_discovery_service.service_discovery.arn
    container_name = var.service_name
  }
}

resource "aws_security_group" "security_group" {
  name        = "${var.service_name}_ecs_sg"
  description = "Allow all outbound traffic"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "HTTP/S Traffic"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = [aws_default_vpc.default_vpc.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# --- Service discovery for elixir clustering
resource "aws_service_discovery_private_dns_namespace" "dns_namespace" {
  name        = "${var.service_name}.local"
  description = "Service discovery for elixir clustering"
  vpc         = aws_default_vpc.default_vpc.id
}

resource "aws_service_discovery_service" "service_discovery" {
  name = var.service_name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.dns_namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }
}