/*
    DATA: THIS IS USED TO GET THE DATA FROM THE OPENSTACK CLOUD.
    IT IS USED TO GET THE IMAGE, FLAVOR, AND NETWORK.
*/
data "openstack_images_image_v2" "cirros" {
    name        = var.image_name
    most_recent = true
}

data "openstack_compute_flavor_v2" "small" {
    name        = var.flavor_name
}

data "openstack_networking_network_v2" "private" {
    name        = var.network_name
}


/*
    OUTPUTS: WHEN USING TERRAFORM APPLY, THESE WILL BE OUTPUTTED TO THE CONSOLE.
    THE OUTPUTS ARE USED TO REFERENCE THE DATA IN THE RESOURCES.
*/
output "image_id" {
    value       = data.openstack_images_image_v2.cirros.id // The ID of the image
}

output "flavor_id" {
    value       = data.openstack_compute_flavor_v2.small.id // The ID of the flavor
}

output "network_id" {
    value       = data.openstack_networking_network_v2.private.id // The ID of the network
}
