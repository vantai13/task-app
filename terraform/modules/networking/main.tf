# Create VPC
# Tôi sẽ sử dụng module VPC có sẵn của terraform để tạo VPC cho nhanh.
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = "Taking-Note-App-VPC"
  cidr = var.cidr_block

  azs             = var.availability_zones
  public_subnets  = var.public_subnet_ips
  private_subnets = var.private_subnet_ips

  enable_nat_gateway = true
  enable_vpn_gateway = false
  single_nat_gateway = true
  tags = {
    Name = "Taking-Note-App-VPC"
  }
}
