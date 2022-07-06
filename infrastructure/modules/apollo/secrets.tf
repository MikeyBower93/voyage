resource "aws_secretsmanager_secret" "service_secret" {
  name = "${var.service_name}_secret"
}

resource "aws_secretsmanager_secret_version" "service_secret_version" {
  secret_id     = aws_secretsmanager_secret.service_secret.id
  secret_string = <<EOF
   {
    "DATABASE_URL": "${var.database_url}",
    "SECRET_KEY_BASE":  "${var.secret_key_base}"
   }
EOF
}