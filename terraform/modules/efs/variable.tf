variable "vpc_id" {
  description = "The ID of the VPC where EFS will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for EFS mount targets"
  type        = list(string)
}

variable "ecs_security_group_id" {
  description = "The security group ID of the ECS tasks that will access EFS"
  type        = string
}

variable "project_name" {
  description = "The name of the project, used for tagging resources"
  type        = string
  default     = "taking-note-app"
}