# Defining VM Volume
resource "libvirt_volume" "rhel9-qcow2" {
  name = "rhel9.qcow2"
  pool = "default" # List storage pools using virsh pool-list
  source = "./packer-rhel-9-x86_64"
  format = "qcow2"
}

# Define KVM domain to create
resource "libvirt_domain" "rhel9" {
  name   = "rhel9"
  memory = "2048"
  vcpu   = 2

  cpu {
    mode = "host-model"
  }

  network_interface {
    network_name   = "default" # List networks with virsh net-list
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.rhel9-qcow2.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }
}

# Output Server IP
output "ip" {
  value = libvirt_domain.rhel9.network_interface.0.addresses.0
}
