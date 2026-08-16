.PHONY: up plan down output

TF_DIR := terraform

up:
	cd $(TF_DIR) && terraform init -input=false && terraform apply -auto-approve

plan:
	cd $(TF_DIR) && terraform plan

down:
	cd $(TF_DIR) && terraform destroy -auto-approve

output:
	cd $(TF_DIR) && terraform output