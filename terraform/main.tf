terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "0.6.14"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }
  }
}

# create ansible groups with input from virtual machine specs in tfvars
locals {
  ansible_sorted_groups = { for k, v in var.vms :
    try(v.group, "ungrouped") => k...
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
      ssh_pub_key_content = file(pathexpand("~/.ssh/${var.ssh_public_key}"))
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
  running     = true

  provisioner "local-exec" {
    command = "ssh-keygen -R ${each.key}.${var.local_domain}"
  }

  network_interface {
    network_name   = "default"
    wait_for_lease = true
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

resource "local_file" "ansible_inventory_file" {
  depends_on = [null_resource.ansible_inventory_dir]
  content = templatefile("${path.module}/templates/ansible_inventory.tftpl",
    {
      ansible_groups = local.ansible_sorted_groups
      local_domain   = var.local_domain
    }
  )
  filename        = "${path.module}/../ansible/inventory/hosts"
  file_permission = "0640"
}

resource "local_file" "ansible_config_file" {
  content = templatefile("${path.module}/templates/ansible_cfg.tftpl",
    {
      ansible_user = var.cloud_user
    }
  )
  filename        = "${path.module}/../ansible/ansible.cfg"
  file_permission = "0640"
}

resource "null_resource" "ansible_inventory_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/../ansible/inventory"
  }
}
