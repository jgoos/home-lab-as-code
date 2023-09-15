terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.7.1"
    }
  }
}

# create ansible groups with input from virtual machine specs in tfvars
locals {
  ansible_sorted_groups = { for k, v in var.vms :
    coalesce(v.group, "ungrouped") => k...
  }
  rhel_versions_in_tfvars = toset([for k, v in var.vms :
    v.rhel_version
  ])
}


provider "libvirt" {
  uri = "qemu:///system"
}

resource "libvirt_volume" "rhel" {
  for_each = local.rhel_versions_in_tfvars
  name     = "rhel${each.key}"
  source   = "../packer/output-rhel${each.key}/packer-rhel-${each.key}-x86_64"
}

resource "libvirt_volume" "worker" {
  for_each       = var.vms
  name           = "${each.key}.qcow2"
  size           = each.value.storage * pow(1024, 3) # convert GB to Bytes
  base_volume_id = libvirt_volume.rhel[each.value.rhel_version].id
}

resource "libvirt_cloudinit_disk" "commoninit" {
  for_each = var.vms
  name     = "${each.key}cloud-init.iso"
  meta_data = templatefile("${path.module}/templates/cloud_init_meta_data.tftpl",
    {
      hostname = "${each.key}"
    }
  )
  user_data = templatefile("${path.module}/templates/cloud_init_user_data.tftpl",
    {
      hostname            = "${each.key}"
      host_fqdn           = "${each.key}.${var.local_domain}"
      cloud_user          = "${var.cloud_user}"
      ssh_pub_key_content = file("~/.ssh/${var.ssh_public_key}")
    }
  )
}

resource "libvirt_domain" "rhel" {
  for_each    = var.vms
  name        = "${each.key}.${var.local_domain}"
  description = "Managed by Terraform"
  memory      = each.value.memory
  vcpu        = each.value.cpu
  cloudinit   = libvirt_cloudinit_disk.commoninit[each.key].id
  running     = each.value.powered_on
  machine     = "q35"
  cpu {
    mode = "host-passthrough"
  }
  # use custom cdrom model that uses sata instead of IDE.
  # IDE controllers are not available with machine type q35.
  # The cloud-init configuration of the libvirt provider still uses IDE for cdrom.
  # See: https://github.com/dmacvicar/terraform-provider-libvirt/issues/885
  xml {
    xslt = file("cdrom-model.xsl")
  }

  provisioner "local-exec" {
    command = "ssh-keygen -R ${each.key}.${var.local_domain}"
  }

  network_interface {
    network_name   = can(each.value.attached_network) ? each.value.attached_network : "default"
    wait_for_lease = true
  }

  disk {
    volume_id = libvirt_volume.worker[each.key].id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "virtio"
  }

  graphics {
    type        = "vnc"
    listen_type = "address"
    autoport    = true
  }

  video {
    type = "virtio"
  }
}

resource "local_file" "ansible_inventory_file" {
  content = templatefile("${path.module}/templates/ansible_inventory.tftpl",
    {
      ansible_groups = local.ansible_sorted_groups
      local_domain   = var.local_domain
    }
  )
  filename        = "${path.module}/../ansible/inventory/hosts"
  file_permission = 640
}

resource "local_file" "ansible_config_file" {
  content = templatefile("${path.module}/templates/ansible_cfg.tftpl",
    {
      ansible_user = var.cloud_user
    }
  )
  filename        = "${path.module}/../ansible/ansible.cfg"
  file_permission = 640
}
