# Defining VM Volume
resource "libvirt_volume" "rhel9" {

  name   = "rhel9"
  source = "./packer-rhel-9-x86_64"
}

resource "libvirt_volume" "worker" {

  name           = "worker_${count.index}.qcow2"
  base_volume_id = libvirt_volume.rhel9.id
  count          = var.workers_count
}

resource "libvirt_domain" "rhel9" {
  count  = var.workers_count
  name   = "domain_${count.index}"
  memory = "1024"
  vcpu   = 1

  network_interface {
    network_name = "default" # List networks with virsh net-list
    wait_for_lease = true
    hostname = "domain_${count.index}"
  }

  cpu {
    mode = "host-model"
  }
  disk {
    volume_id = element(libvirt_volume.worker.*.id, count.index)
  }

  graphics {
    type = "vnc"
  }

  // ...
}
