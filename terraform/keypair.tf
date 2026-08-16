resource "openstack_compute_keypair_v2" "lab" {
    name = var.keypair_name
    public_key = file(pathexpand(var.public_key_path))
}