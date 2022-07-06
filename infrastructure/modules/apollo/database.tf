resource "aws_db_instance" "database" {
  db_name                = var.service_name
  identifier             = "${var.service_name}-database"
  instance_class         = "db.t3.micro"
  allocated_storage      = 5
  engine                 = "postgres"
  engine_version         = "14.2"
  username               = var.service_name
  password               = var.database_password
  vpc_security_group_ids = [aws_security_group.rds_security_group.id]
  skip_final_snapshot    = true
}

resource "aws_security_group" "rds_security_group" {
  name        = "${var.service_name}_rds_sg"
  description = "Allow all outbound traffic"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description = "Postgres Traffic"
    from_port   = 5432
    to_port     = 5432
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
