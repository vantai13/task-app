output "bastion_public_ip" {
  description = "Public IP address of the Bastion host"
  value       = aws_instance.bastion.public_ip
}
output "bastion_security_group_id" {
  description = "The ID of the Bastion Security Group"
  value       = aws_security_group.bastion_sg.id
}