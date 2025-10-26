output "application_url" {
  description = "URL của ứng dụng:"
  value       = "https://taking-note-app.vantai.click"
}

output "load_balancer_dns" {
  description = "DNS của ALB"
  value       = module.load_balance.alb_dns_name 
}

output "IP_bastion" {
  description = "IP của Bastion Host"
  value       = module.bastion.bastion_public_ip
}
