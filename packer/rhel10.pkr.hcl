source "qemu" "rhel10" {
  qemu_binary = "/usr/libexec/qemu-kvm"
  qemuargs = [
    ["-display", "none"],
    ["-cpu", "host"]
  ]
  iso_url                = "iso-files/rhel-10.1-x86_64-dvd.iso"
  iso_checksum           = "sha256:5925e05c32d8324a72e146a29293d60707571817769de73df63eab8dbd6d3196"
  cd_label               = "CIDATA"
  cd_files               = ["config/ks-el10.cfg", "config/cloud.cfg"]
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
  vm_name                = "packer-rhel-10-x86_64"
  net_device             = "virtio-net"
  disk_interface         = "virtio"
  boot_wait              = "15s"
  boot_command           = ["<up><wait><tab><wait> inst.text inst.ksstrict inst.ks=cdrom:/dev/sr1:/ks-el10.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.rhel10"]
  post-processor "shell-local" {
    inline = ["virt-sysprep -a output-rhel10/packer-rhel-10-x86_64 --operations defaults,-lvm-uuids --run-command '> /etc/machine-id'"]
  }
}
