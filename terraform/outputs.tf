output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  value = aws_subnet.private_app[*].id
}

output "private_db_subnet_ids" {
  value = aws_subnet.private_db[*].id
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
}

output "ec2_iam_role" {
  value = aws_iam_role.ec2_role.name
}

output "ec2_instance_profile" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
}

output "ec2_instance_id" {
  value = aws_instance.app_server.id
}

output "ec2_private_ip" {
  value = aws_instance.app_server.private_ip
}

output "alb_dns_name" {
  value = aws_lb.app_alb.dns_name
}

output "alb_target_group_arn" {
  value = aws_lb_target_group.app_tg.arn
}

output "rds_endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "rds_address" {
  value = aws_db_instance.postgres.address
}

output "rds_port" {
  value = aws_db_instance.postgres.port
}

output "rds_database_name" {
  value = aws_db_instance.postgres.db_name
}

output "rds_secret_arn" {
  value = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

output "app_db_secret_arn" {
  value = aws_secretsmanager_secret.app_db.arn
}