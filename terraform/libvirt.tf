resource "libvirt_network" "terraform_local_dns" {
  name      = "terraform_local_dns"
  mode      = "nat"
  domain    = var.local_domain
  addresses = ["192.168.123.0/24"]
  dhcp {
    enabled = true
  }

  dns {
    local_only = true
  }
}

resource "libvirt_volume" "rhel9" {
  name   = "rhel9"
  source = "../packer/rhel9/builds/packer-rhel-9-x86_64"
}

resource "libvirt_volume" "worker" {
  for_each       = var.vm
  name           = "${each.key}.qcow2"
  size           = each.value.storage * 1024 * 1024 * 1024 # convert GB to Bytes
  base_volume_id = libvirt_volume.rhel9.id
}

data "template_file" "user_data" {
  for_each = var.vm
  template = file("${path.module}/cloud_init_user_data.tmpl")
  vars = {
    hostname            = "${each.key}"
    host_fqdn           = "${each.value.fqdn}"
    cloud_user          = "${var.cloud_user}"
    ssh_pub_key_content = file("~/.ssh/${var.ssh_public_key}")
  }
}

data "template_file" "meta_data" {
  for_each = var.vm
  template = file("${path.module}/cloud_init_meta_data.tmpl")
  vars = {
    hostname = "${each.key}"
  }
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each  = var.vm
  name      = "${each.key}cloud-init.iso"
  user_data = data.template_file.user_data[each.key].rendered
  meta_data = data.template_file.meta_data[each.key].rendered
}

resource "libvirt_domain" "rhel9" {
  for_each  = var.vm
  name      = each.key
  memory    = each.value.memory
  vcpu      = each.value.cpu
  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

  network_interface {
    network_name   = "terraform_local_dns"
    wait_for_lease = true
    hostname       = each.value.fqdn
  }

  cpu {
    mode = "host-model"
  }
  disk {
    volume_id = libvirt_volume.worker[each.key].id
  }

  graphics {
    type = "vnc"
  }
}
