output "target_group_arn" {
  value = aws_lb_target_group.taking_note_app_target_group.arn
}
output "alb_arn" {
  value = aws_lb.load_balancer.arn
}
output "alb_dns" {
  value = aws_lb.load_balancer.dns_name
}
output "alb_dns_name" {
  description = "DNS name của ALB"
  value       = aws_lb.load_balancer.dns_name
}

output "alb_zone_id" {
  description = "Zone ID của ALB"
  value       = aws_lb.load_balancer.zone_id
}