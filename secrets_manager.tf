# Generate a random password for the database
resource "random_password" "db_password" {
  length  = 8
  special = false
}

# Generate a random name for the secret manager
resource "random_string" "secret_name" {
  length  = 10
  special = false
}

# Store database password in Secrets Manager
resource "aws_secretsmanager_secret" "db_password_secret" {
  name                    = random_string.secret_name.result
  description             = "Database password for the ${var.vpc_name} application"
  kms_key_id              = aws_kms_key.secrets_encryption_key.arn
  recovery_window_in_days = 7

  tags = {
    Name = "DB-Password-Secret-${var.vpc_name}"
  }
}

resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id = aws_secretsmanager_secret.db_password_secret.id
  secret_string = jsonencode({
    password = random_password.db_password.result
  })
}
