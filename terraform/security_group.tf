/*
    For this resource, we need to create a new security group in the OpenStack cloud.
    name - dpaas-lab-sg
    description - Lab SG: ICMP + SSH
            {
                SG: ICMP + SSH
                ICMP = Internet Control Message Protocol - used to test connectivity
                SSH = Secure Shell - used to connect to the instance
                SG = Security Group - used to group rules together
            }
    add ICMP and SSH rules
    print useful values after apply
*/

resource "openstack_networking_secgroup_v2" "lab" {
    name        = var.sg_name
    description = "Lab SG: ICMP + SSH"
}


/*
    "ingress" Traffic is coming into the instance
    "egress" Traffic is going out of the instance

    "----Protocols-----"
    "tcp" = Transmission Control Protocol - used to send and receive data
    "udp" = User Datagram Protocol - used to send and receive data
    "icmp" = Internet Control Message Protocol - used to test connectivity

    "----Ethertypes-----"
    "IPv4" = Internet Protocol Version 4 - used to send and receive data
    "IPv6" = Internet Protocol Version 6 - used to send and receive data
*/
resource "openstack_networking_secgroup_rule_v2" "icmp" {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "icmp"
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.lab.id
}

resource "openstack_networking_secgroup_rule_v2" "ssh" {
    direction         = "ingress"
    ethertype         = "IPv4"
    protocol          = "tcp"
    port_range_min    = 22
    port_range_max    = 22
    remote_ip_prefix  = "0.0.0.0/0"
    security_group_id = openstack_networking_secgroup_v2.lab.id
}