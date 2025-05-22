variable "rhel_builds" {
  type = map(object({
    iso_url      = string
    iso_checksum = string
    ks_file      = string
  }))
  default = {
    "7" = {
      iso_url      = "iso-files/rhel-server-7.9-x86_64-dvd.iso"
      iso_checksum = "sha256:19d653ce2f04f202e79773a0cbeda82070e7527557e814ebbce658773fbe8191"
      ks_file      = "config/ks-el7.cfg"
    }
    "8" = {
      iso_url      = "iso-files/rhel-8.6-x86_64-dvd.iso"
      iso_checksum = "sha256:c324f3b07283f9393168f0a4ad2167ebbf7e4699d65c9670e0d9e58ba4e2a9a8"
      ks_file      = "config/ks-el8.cfg"
    }
    "9" = {
      iso_url      = "iso-files/rhel-baseos-9.0-x86_64-dvd.iso"
      iso_checksum = "sha256:a387f3230acf87ee38707ee90d3c88f44d7bf579e6325492f562f0f1f9449e89"
      ks_file      = "config/ks-el9.cfg"
    }
  }
}

source "qemu" "rhel" {
  for_each = var.rhel_builds

  qemu_binary = "/usr/libexec/qemu-kvm"
  qemuargs = [
    ["-display", "none"],
    ["-cpu", "host"],
  ]
  iso_url                = each.value.iso_url
  iso_checksum           = each.value.iso_checksum
  cd_label               = "CIDATA"
  cd_files               = [each.value.ks_file, "config/cloud.cfg"]
  communicator           = "ssh"
  shutdown_command       = "echo 'packer' | sudo -S shutdown -P now"
  disk_size              = "10G"
  memory                 = "1024"
  cpus                   = "1"
  format                 = "qcow2"
  accelerator            = "kvm"
  ssh_username           = "cloud-user"
  ssh_password           = "cloud-user"
  ssh_timeout            = "20m"
  ssh_handshake_attempts = "20"
  headless               = true
  vm_name                = "packer-rhel-${each.key}-x86_64"
  net_device             = "virtio-net"
  disk_interface         = "virtio"
  boot_wait              = "15s"
  boot_command           = [
    "<up><wait><tab><wait> inst.text inst.ksstrict inst.ks=cdrom:/dev/sr1:/ks-el${each.key}.cfg<enter><wait>"
  ]
}

build {
  for_each = var.rhel_builds
  sources = ["source.qemu.rhel.${each.key}"]

  post-processor "shell-local" {
    inline = [
      "virt-sysprep -a output-rhel${each.key}/packer-rhel-${each.key}-x86_64 --operations defaults,-lvm-uuids --run-command '> /etc/machine-id'"
    ]
  }
}
