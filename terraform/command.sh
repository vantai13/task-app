
terraform init
terraform plan --var-file "terraform.tfvars"
terraform apply --var-file "terraform.tfvars"
terraform destroy --var-file "terraform.tfvars"

# ssh basetion host 
#ssh -i <Đường_dẫn_Private_Key> -N -L 3307:<RDS_Endpoint>:3306 ec2-user@<Bastion_Public_IP>

ssh -i  -N -L 3307:taking-note-db.chi0awig8v33.ap-southeast-1.rds.amazonaws.com:3306 ec2-user@54.151.215.184
