
terraform init


terraform plan -target="module.networking"
terraform apply -target="module.networking"

terraform plan --var-file "terraform.tfvars"
terraform apply --var-file "terraform.tfvars"
terraform destroy --var-file "terraform.tfvars"

terrform destroy 

# ssh basetion host 
#ssh -i <Đường_dẫn_Private_Key> -N -L 3307:<RDS_Endpoint>:3306 ec2-user@<Bastion_Public_IP>

ssh -i  -N -L 3307:taking-note-db.chi0awig8v33.ap-southeast-1.rds.amazonaws.com:3306 ec2-user@13.250.27.34

# Dùng hey để tấn công dung lượng
hey -z 10m -c 100 -H "Cookie: session=.eJwljjEOwzAIAP_iuQMYsEM-E4HBatekmar-vZY63umG-5Rjnnk9y_4-73yU4xVlL2Ob1QZzcE2lxk1iTmquzgN9UmeS2VkDhEPDwAgDNkFiHX16h2FLmUjzzS0GVKkKKJhunXtdoFRBbNWZMbyhGjJY9KSoZY3cV57_GyzfH8KoL0o.aPxGvg.62kM73q5tkvXUS0eYjw_j0Tfs34" https://taking-note-app.vantai.click/heavy

