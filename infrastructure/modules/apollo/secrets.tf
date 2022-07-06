resource "aws_secretsmanager_secret" "service_secret" {
  name = "${var.service_name}_secret"
}

resource "aws_secretsmanager_secret_version" "service_secret_version" {
  secret_id     = aws_secretsmanager_secret.service_secret.id
  secret_string = <<EOF
   {
    "DATABASE_URL": "ecto://${aws_db_instance.database.username}:${aws_db_instance.database.password}@${aws_db_instance.database.address}/${var.service_name}",
    "SECRET_KEY_BASE":  "${var.secret_key_base}"
   }
EOF
}