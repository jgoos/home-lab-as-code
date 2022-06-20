resource "libvirt_volume" "rhel" {
  name   = "rhel"
  source = "../packer/rhel${var.rhel_version}/builds/packer-rhel-${var.rhel_version}-x86_64"
}

resource "libvirt_volume" "worker" {
  for_each       = var.vm
  name           = "${each.key}.qcow2"
  size           = each.value.storage * 1024 * 1024 * 1024 # convert GB to Bytes
  base_volume_id = libvirt_volume.rhel.id
}

data "template_file" "user_data" {
  for_each = var.vm
  template = file("${path.module}/cloud_init_user_data.tmpl")
  vars = {
    hostname            = "${each.value.hostname}"
    host_fqdn           = "${each.value.hostname}.${var.local_domain}"
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

resource "libvirt_domain" "rhel" {
  for_each  = var.vm
  name      = "${each.key}.${var.local_domain}"
  description = "Managed by Terraform"
  memory    = each.value.memory
  vcpu      = each.value.cpu
  cloudinit = libvirt_cloudinit_disk.commoninit[each.key].id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
    hostname       = "${each.value.hostname}.${var.local_domain}"
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
