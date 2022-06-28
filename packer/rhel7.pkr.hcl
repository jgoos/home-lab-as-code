source "qemu" "rhel7" {
  qemu_binary = "/usr/libexec/qemu-kvm"
  qemuargs = [
    ["-display", "none"],
    ["-cpu", "host"]
  ]
  iso_url                = "iso-files/rhel-server-7.9-x86_64-dvd.iso"
  iso_checksum           = "sha256:19d653ce2f04f202e79773a0cbeda82070e7527557e814ebbce658773fbe8191"
  cd_label               = "CIDATA"
  cd_files               = ["config/ks-el7.cfg", "config/cloud.cfg"]
  communicator           = "ssh"
  output_directory       = "builds"
  shutdown_command       = "echo 'packer' | sudo -S shutdown -P now"
  disk_size              = "20G"
  memory                 = "4096"
  cpus                   = "1"
  format                 = "qcow2"
  accelerator            = "kvm"
  ssh_username           = "cloud-user"
  ssh_password           = "cloud-user"
  ssh_timeout            = "20m"
  ssh_handshake_attempts = "20"
  headless               = true
  vm_name                = "packer-rhel-7-x86_64"
  net_device             = "virtio-net"
  disk_interface         = "virtio"
  boot_wait              = "15s"
  boot_command           = ["<up><wait><tab><wait> inst.text inst.ksstrict inst.ks=cdrom:/dev/sr1:/ks-el7.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.rhel7"]
}
