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
              "logs:PutLogEvents",
              "ssm:GetParameters",
              "secretsmanager:GetSecretValue"
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

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.service_name}"
}

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
          "awslogs-region": "${var.region}",
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
      "secrets": [
        {
          "name": "SECRET_KEY_BASE",
          "valueFrom": "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:SECRET_KEY_BASE"
        },
        {
          "name": "DATABASE_URL",
          "valueFrom": "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:DATABASE_URL"
        }
      ],
      "mountPoints": [],
      "volumesFrom": [],
      "essential": true,
      "links": [],
      "name": "${var.service_name}"
    }
  ]
  EOF
}

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
