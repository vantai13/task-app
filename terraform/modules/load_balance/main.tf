#Application Load Balancer
resource "aws_lb" "load_balancer" {
  name               = "taking-note-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.load_balance_security_group_ids
  subnets            = var.load_balance_subnet_ids
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60
  enable_cross_zone_load_balancing = true
  tags = {
    Name = "taking-note-app-alb"
  }
}

#Load Balancer Listener
resource "aws_lb_listener" "listener_https" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08" # Một chính sách SSL tốt
  certificate_arn   = var.certificate_arn       # Sử dụng chứng chỉ bạn truyền vào

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.taking_note_app_target_group.arn
  }
}

resource "aws_lb_listener" "listener_http_redirect" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301" # Chuyển hướng vĩnh viễn
    }
  }
}
#Target Group
resource "aws_lb_target_group" "taking_note_app_target_group" {
  name        = "target-group"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  health_check {
    path                = "/health"
    protocol            = "HTTP"
    port                = "5000"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200,301,302"
  }
  
  # stickiness {
  #   type            = "lb_cookie" # Bảo ALB tự tạo và quản lý cookie
  #   cookie_duration = 86400       # "Dính" với server đó trong 86400 giây (1 ngày)
  #   enabled         = true
  # }
}