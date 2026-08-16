variable "os_auth_url" {
    description = "Keystone auth URL for the local DevStack lab"
    type        = string
}

variable "os_username" {
    description = "OpenStack username (Keystone), usually admin on DevStack"
    type        = string
}

variable "os_password" {
    description = "OpenStack password (matches DevStack ADMIN_PASSWORD)"
    type        = string
    sensitive   = true
}

variable "os_project_name" {
    description = "OpenStack project / tenant name"
    type        = string
}

variable "os_user_domain_name" {
    description = "Domain name for the user"
    type        = string
    default     = "Default"
}

variable "os_project_domain_name" {
    description = "Domain name for the project"
    type        = string
    default     = "Default"
}

variable "os_region_name" {
    description = "OpenStack region"
    type        = string
    default     = "RegionOne"
}


variable "vm_name" {
    type    = string
    default = "dpaas-tf-vm"
}

variable "image_name" {
    type    = string
    default = "cirros-0.6.3-aarch64-disk"
}

variable "flavor_name" {
    type    = string
    default = "cirros256"
}

variable "network_name" {
    type    = string
    default = "private"
}

variable "keypair_name" {
    type    = string
    default = "dpaas-lab-key"
}

variable "sg_name" {
    type    = string
    default = "dpaas-lab-sg"
}

variable "public_key_path" {
    type    = string
    default = "~/.ssh/dpaas_lab.pub"
}