source "qemu" "rhel8" {
  qemu_binary = "/usr/libexec/qemu-kvm"
  qemuargs = [
    ["-display", "none"],
    ["-cpu", "host"]
  ]
  iso_url                = "iso-files/rhel-8.8-x86_64-dvd.iso"
  iso_checksum           = "sha256:517abcc67ee3b7212f57e180f5d30be3e8269e7a99e127a3399b7935c7e00a09"
  cd_label               = "CIDATA"
  cd_files               = ["config/ks-el8.cfg", "config/cloud.cfg"]
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
  vm_name                = "packer-rhel-8-x86_64"
  net_device             = "virtio-net"
  disk_interface         = "virtio"
  boot_wait              = "15s"
  boot_command           = ["<up><wait><tab><wait> inst.text inst.ksstrict inst.ks=cdrom:/dev/sr1:/ks-el8.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.rhel8"]
  post-processor "shell-local" {
    inline = ["virt-sysprep -a output-rhel8/packer-rhel-8-x86_64 --operations defaults,-lvm-uuids --run-command '> /etc/machine-id'"]
  }
}
