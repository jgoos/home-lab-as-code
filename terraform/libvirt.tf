# Read ssh public key that is used via cloud-init
data "local_file" "ssh" {
  filename = pathexpand("~/.ssh/id_ed25519")
  #filename = "${path.module}/.cch/key"
}

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

#data "template_file" "user_data" {
#  template = file("${path.module}/cloud_init.tmpl")
#}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name      = "commoninit.iso"
  user_data = data.template_file.user_data.rendered
}

resource "libvirt_domain" "rhel9" {
  count  = var.workers_count
  name   = "domain_${count.index}"
  memory = "1024"
  vcpu   = 1

  cloudinit = libvirt_cloudinit_disk.commoninit.id

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
