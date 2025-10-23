# --- terraform/modules/rds/variables.tf ---

variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "The security group ID used by ECS tasks"
  type        = string
}

variable "db_username" {
  description = "Username for the RDS instance creation"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password for the RDS instance creation"
  type        = string
  sensitive   = true
}

variable "bastion_security_group_id" {
  description = "The security group ID used by the Bastion host"
  type        = string
  # Có thể để trống nếu không phải lúc nào cũng có bastion
  # default     = null 
}