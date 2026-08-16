# Terraform — local DevStack lab

Creates: keypair + security group (ICMP/SSH) + Cirros VM on `private`.

## Prerequisites

1. UTM DevStack VM running
2. `terraform.tfvars` filled (copy from `terraform.tfvars.example`)
3. SSH pubkey at `~/.ssh/dpaas_lab.pub`

## One-command path (from repo root)

```bash
make up      # terraform init + apply
make plan    # preview
make output  # show IPs / ids
make down    # destroy lab resources