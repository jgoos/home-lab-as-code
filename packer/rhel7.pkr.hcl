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
  vm_name                = "packer-rhel-7-x86_64"
  net_device             = "virtio-net"
  disk_interface         = "virtio"
  boot_wait              = "15s"
  boot_command           = ["<up><wait><tab><wait> inst.text inst.ksstrict inst.ks=cdrom:/dev/sr1:/ks-el7.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.rhel7"]
  post-processor "shell-local" {
    inline = ["virt-sysprep -a output-rhel7/packer-rhel-7-x86_64 --operations defaults,-lvm-uuids --run-command '> /etc/machine-id'"]
  }
}
