variable "vpc_id" {
  description = "VPC ID where the bastion will be created"
  type        = string
}

variable "public_subnet_id" {
  description = "A public subnet ID for the bastion instance"
  type        = string
}

variable "rds_sg_id" {
  description = "Security group ID of the RDS instance"
  type        = string
}

variable "key_pair_name" {
  description = "Name of the EC2 Key Pair to use for SSH access"
  type        = string
}

variable "my_public_ip" {
  description = "Your public IP address for SSH access to the bastion"
  type        = string
  sensitive   = true # Không hiển thị IP trong log
}

variable "ami_id" {
  description = "AMI ID for the bastion instance (Linux 24)."
  type        = string
  default     = "ami-0933f1385008d33c4" # AMI cho ap-southeast-1
}

variable "instance_type" {
  description = "EC2 instance type for the bastion"
  type        = string
  default     = "t2.micro"
}
