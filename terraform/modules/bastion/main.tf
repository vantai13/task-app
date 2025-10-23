# Security Group cho Bastion Host
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-host-module-sg"
  description = "Allow SSH inbound from my IP and outbound to RDS"
  vpc_id      = var.vpc_id

  # Cho phép SSH vào từ IP của bạn
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.my_public_ip] # Chỉ cho phép IP của bạn
    #cidr_blocks = ["0.0.0.0/0"]
  }

  # # Cho phép Bastion kết nối ra RDS
  # egress {
  #   protocol        = "tcp"
  #   from_port       = 3306
  #   to_port         = 3306
  #   security_groups = [var.rds_sg_id] # Kết nối đến SG của RDS
  # }

  # Cho phép Bastion kết nối ra Internet
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "BastionHostSG (Module)"
  }
}

# EC2 Instance làm Bastion Host
resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id # Đặt trong public subnet
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name      = var.key_pair_name # Dùng key pair đã có
  associate_public_ip_address = true

  tags = {
    Name = "BastionHost"
  }
}