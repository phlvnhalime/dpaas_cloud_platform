resource "openstack_compute_keypair_v2" "lab" {
    name = "dpaas-lab-key"
    public_key = file(pathexpand("~/.ssh/dpaas_lab.pub"))
}