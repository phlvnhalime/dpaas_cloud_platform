/*
    For this resource, we need to create a new instance in the OpenStack cloud.
    disk image - reuse Day 3 data lookup
    Size - reuse Day 3 data lookup
    attached to private network
    print useful values after apply
*/

resource "openstack_compute_instance_v2" "lab" {
    name = "dpaas-tf-vm"
    image_id = data.openstack_images_image_v2.cirros.id
    flavor_id = data.openstack_compute_flavor_v2.small.id

    network {
        uuid = data.openstack_networking_network_v2.private.id
    }
}

output "vm_name" {
    value = openstack_compute_instance_v2.lab.name
}

output "vm_id" {
    value = openstack_compute_instance_v2.lab.id
}

output "vm_access_ip_v4" {
    value = openstack_compute_instance_v2.lab.access_ip_v4
}