source "qemu" "rhel8" {
  qemu_binary = "/usr/libexec/qemu-kvm"
  qemuargs = [
    ["-display", "none"],
    ["-cpu", "host"]
  ]
  iso_url                = "../../iso-files/rhel-8.6-x86_64-dvd.iso"
  iso_checksum           = "sha256:c324f3b07283f9393168f0a4ad2167ebbf7e4699d65c9670e0d9e58ba4e2a9a8"
  cd_files               = ["config/ks-el8.cfg"]
  output_directory       = "builds"
  shutdown_command       = "echo 'packer' | sudo -S shutdown -P now"
  disk_size              = "10G"
  memory                 = "4096"
  cpus                   = "1"
  format                 = "qcow2"
  accelerator            = "kvm"
  ssh_password           = "vagrant"
  ssh_username           = "vagrant"
  ssh_timeout            = "20m"
  ssh_handshake_attempts = "15"
  headless               = true
  vm_name                = "packer-rhel-8-x86_64"
  net_device             = "virtio-net"
  disk_interface         = "virtio"
  boot_wait              = "15s"
  boot_command           = ["<up><wait><tab><wait> inst.text inst.ksstrict inst.ks=cdrom:/dev/sr1:/ks-el8.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.rhel8"]
}
