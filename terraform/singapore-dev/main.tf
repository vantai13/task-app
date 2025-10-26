terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
  
}

provider "aws" {
  region = var.region
}

resource "aws_key_pair" "bastion_key" {
  # Đây là tên mà AWS sẽ dùng để nhận dạng key pair này
  key_name   = "vantai-key" 

  # Đường dẫn tương đối từ thư mục root module (singapore-dev)
  # Đi lên một cấp (..) rồi vào thư mục keypair
  public_key = file("../keypair/vantai-key.pub") 
}

#Create a complete VPC using module networking
module "networking" {
  source              = "../modules/networking"
  region              = var.region
  availability_zones  = var.availability_zones
  cidr_block          = var.cidr_block
  public_subnet_ips   = var.public_subnet_ips
  private_subnet_ips  = var.private_subnet_ips
}

module "security" {
  source = "../modules/security"
  region = var.region
  vpc_id = module.networking.vpc_id
}

module "load_balance" {
  source                 = "../modules/load_balance"
  region                 = var.region
  vpc_id                 = module.networking.vpc_id
  load_balance_subnet_ids = module.networking.public_subnet_ids
  load_balance_security_group_ids = [
    module.security.public_security_group_id
  ]
  certificate_arn = aws_acm_certificate_validation.cert_validation_wait.certificate_arn

}

module "rds" {
  source                = "../modules/rds"
  vpc_id                = module.networking.vpc_id
  private_subnet_ids    = module.networking.private_subnet_ids
  # Lấy ID của SG mà ECS task dùng (private_sg) từ module security
  ecs_security_group_id = module.security.private_security_group_id 
  db_username           = var.db_username # Lấy từ biến root
  db_password           = var.db_password # Lấy từ biến root
  bastion_security_group_id = module.bastion.bastion_security_group_id
}

module "ecs_cluster"{
  source = "../modules/ecs_cluster"
  
  region                             = var.region
  vpc_id                             = module.networking.vpc_id
  ecs_subnet_ids                     = module.networking.private_subnet_ids
  ecs_security_group_ids             = [module.security.private_security_group_id]
  alb_arn                            = module.load_balance.alb_arn
  taking_note_app_target_group_arn = module.load_balance.target_group_arn
  taking_note_app_ecr_repository_uri = var.ecr_repo_url # Đảm bảo tên biến var.ecr_repo_url đúng

 
  
  db_endpoint   = module.rds.db_instance_endpoint
  db_name       = module.rds.db_instance_name
  db_secret_arn = var.db_secret_arn # Lấy từ biến root
}

# module "efs" {
#   source = "../modules/efs"

#   vpc_id                = module.networking.vpc_id
#   private_subnet_ids    = module.networking.private_subnet_ids
#   # Giả sử private_security_group_id là SG của ECS tasks
#   ecs_security_group_id = module.security.private_security_group_id
# }

module "bastion" {
  source = "../modules/bastion"

  vpc_id           = module.networking.vpc_id
  public_subnet_id = module.networking.public_subnet_ids[0] # Lấy subnet public đầu tiên
  rds_sg_id        = module.rds.rds_security_group_id       # Lấy từ output module RDS
  key_pair_name    = aws_key_pair.bastion_key.key_name                     # Lấy từ biến gốc
  my_public_ip     = var.my_public_ip                       # Lấy từ biến gốc
  # ami_id         = "ami-xxxxxxxxxxxxxxxxx" # Có thể override AMI nếu cần
  # instance_type  = "t3.micro"            # Có thể override loại instance nếu cần
} 

# Lấy zone ID của tên miền vantai.click
data "aws_route53_zone" "primary" {
  name         = "vantai.click"
  private_zone = false
}

# Tạo chứng chỉ ACM cho tên miền và wildcard
resource "aws_acm_certificate" "app_cert" {
  domain_name       = "*.vantai.click"
  subject_alternative_names = ["vantai.click"]
  validation_method = "DNS"

  tags = {
    Name = "vantai-click-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Tạo các bản ghi DNS để xác thực chứng chỉ ACM
resource "aws_route53_record" "cert_validation" {
  # Dùng for_each để tạo record cho cả *.vantai.click và vantai.click
  for_each = {
    for dvo in aws_acm_certificate.app_cert.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      record  = dvo.resource_record_value
      type    = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.primary.zone_id
}

# Việc này đảm bảo Terraform không gắn 1 cert chưa valid vào ALB
resource "aws_acm_certificate_validation" "cert_validation_wait" {
  certificate_arn         = aws_acm_certificate.app_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

resource "aws_route53_record" "app_dns" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = "taking-note-app" # Nó sẽ tự thêm ".vantai.click"
  type    = "A"

  alias {
    # Lấy thông tin DNS của ALB từ output của module "load_balance"
    name                   = module.load_balance.alb_dns_name
    zone_id                = module.load_balance.alb_zone_id
    evaluate_target_health = true
  }
}