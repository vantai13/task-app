variable "region" {
  type = string
  default = "ap-southeast-1"
}

variable "vpc_id" {
  type = string
  description = "The VPC ID to ALB and Target Group"
  nullable = false
}

variable "ecs_subnet_ids" {
  type = list(string)
  description = "The subnet IDs to launch ECS Service"
  nullable = false  
}

variable "ecs_security_group_ids" {
  type = list(string)
  nullable = false
}
variable "alb_arn" {
  type = string
  description = "The ARN of the Application Load Balancer"
  nullable = false
}
variable "taking_note_app_target_group_arn" {
  type = string
  description = "The ARN of the target group for the ECS Service"
  nullable = false
}
variable "taking_note_app_ecr_repository_uri" {
  type = string
  description = "The URI of the ECR repository for the taking_note_app application"
  nullable = false
}

variable "efs_file_system_id" {
  description = "The ID of the EFS File System"
  type        = string
  default     = null # Để null để module vẫn chạy được nếu không có EFS
}

variable "efs_access_point_id" {
  description = "The ID of the EFS Access Point"
  type        = string
  default     = null # Để null để module vẫn chạy được nếu không có EFS
}