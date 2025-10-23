variable "region" {
  type = string
  default = "ap-southeast-1"
}

#parameters for networking module
variable "availability_zones" {
  type = list(string)
  nullable = false
}
variable "cidr_block" {
  type = string
  nullable = false
}
variable "public_subnet_ips" {
  type = list(string)
  nullable = false
  
}
variable "private_subnet_ips" {
  type = list(string)
  nullable = false
}

variable "ecr_repo_url" {
  type = string
  description = "The URI of the ECR repository for the Node.js application"
  nullable = false
}

variable "db_username" {
  description = "Username for the RDS database."
  type        = string
  sensitive   = true 
}

variable "db_password" {
  description = "Password for the RDS database."
  type        = string
  sensitive   = true 
}

variable "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding DB credentials"
  type        = string
  sensitive   = true 
}



variable "my_public_ip" {
  description = "Your public IP address for SSH access"
  type        = string
  sensitive   = true
}