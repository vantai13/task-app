 output "service_arn" {
   description = "ARN of the ECS service"
   value       = aws_ecs_service.taking_note_app_service.id # Hoặc .arn tùy phiên bản provider
 }