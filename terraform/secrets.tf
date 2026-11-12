resource "aws_secretsmanager_secret" "app_db" {
  name                    = "${var.project_name}/database/application"
  description             = "Task Manager application database credentials"
  recovery_window_in_days = 7

  tags = {
    Name = "${var.project_name}-app-db-secret"
  }
}

# Allow EC2 to retrieve only the required database secrets
resource "aws_iam_role_policy" "read_database_secrets" {
  name = "${var.project_name}-read-db-secrets"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Action = [
        "secretsmanager:GetSecretValue"
      ]

      Resource = [
        aws_db_instance.postgres.master_user_secret[0].secret_arn,
        aws_secretsmanager_secret.app_db.arn
      ]
    }]
  })
}