resource "aws_secretsmanager_secret" "db-creads" {
  name = "databse-password"
}

resource "aws_secretsmanager_secret_version" "example" {
  secret_id     = aws_secretsmanager_secret.db-creads.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
  })
}