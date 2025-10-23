# --- terraform/modules/rds/outputs.tf ---

output "db_instance_endpoint" {
  description = "The connection endpoint for the database instance"
  value       = aws_db_instance.mysql_db.endpoint
}

output "db_instance_name" {
  description = "The database name"
  value       = aws_db_instance.mysql_db.db_name
}

output "rds_security_group_id" {
  description = "The ID of the RDS Security Group"
  value       = aws_security_group.rds_sg.id
}