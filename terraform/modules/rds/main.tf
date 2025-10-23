# --- terraform/modules/rds/main.tf ---

resource "aws_security_group" "rds_sg" {
  name        = "taking-note-rds-sg"
  description = "Allow MySQL traffic from ECS tasks"
  vpc_id      = var.vpc_id # Lấy từ input

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    # Cho phép từ SG của ECS tasks
    security_groups = [var.ecs_security_group_id] 
  }

  ingress {
    protocol        = "tcp"
    from_port       = 3306
    to_port         = 3306
    # Sử dụng biến input mới
    security_groups = [var.bastion_security_group_id] 
    description     = "Allow MySQL from Bastion Host" # Thêm mô tả
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "taking-note-rds-sg"
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "taking-note-db-subnet-group"
  subnet_ids = var.private_subnet_ids # Lấy từ input

  tags = {
    Name = "Taking Note DB Subnet Group"
  }
}

resource "aws_db_instance" "mysql_db" {
  identifier           = "taking-note-db"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "takingnoteapp"
  username             = var.db_username # Lấy từ input
  password             = var.db_password # Lấy từ input
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot  = true

  tags = {
    Name = "taking-note-db"
  }
}