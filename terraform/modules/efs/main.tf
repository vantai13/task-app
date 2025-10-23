# # Security Group cho phép ECS truy cập EFS qua cổng NFS
# resource "aws_security_group" "efs_sg" {
#   name        = "${var.project_name}-efs-sg"
#   description = "Allow inbound NFS traffic from ECS tasks"
#   vpc_id      = var.vpc_id

#   # Cho phép traffic NFS (cổng 2049) từ security group của ECS
#   ingress {
#     protocol        = "tcp"
#     from_port       = 2049
#     to_port         = 2049
#     security_groups = [var.ecs_security_group_id]
#   }

#   # Cho phép tất cả traffic đi ra
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "${var.project_name}-efs-sg"
#   }
# }

# # Tạo EFS File System
# resource "aws_efs_file_system" "this" {
#   creation_token = "${var.project_name}-efs"
#   tags = {
#     Name = "${var.project_name}-efs"
#   }
# }

# # Tạo các Mount Target trong từng private subnet để ECS tasks có thể kết nối
# resource "aws_efs_mount_target" "this" {
#   for_each = toset(var.private_subnet_ids)

#   file_system_id  = aws_efs_file_system.this.id
#   subnet_id       = each.value
#   security_groups = [aws_security_group.efs_sg.id]
# }

# # Tạo Access Point để ứng dụng truy cập EFS một cách có kiểm soát
# resource "aws_efs_access_point" "this" {
#   file_system_id = aws_efs_file_system.this.id

#   # Cấu hình thư mục gốc và quyền sở hữu cho ứng dụng
#   root_directory {
#     path = "/data"
#     creation_info {
#       owner_gid   = 1000
#       owner_uid   = 1000
#       permissions = "755"
#     }
#   }

#   # Cấu hình user ID và group ID khi ứng dụng mount vào EFS
#   posix_user {
#     gid = 1000
#     uid = 1000
#   }

#   tags = {
#     Name = "${var.project_name}-efs-ap"
#   }
# }