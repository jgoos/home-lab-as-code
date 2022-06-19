source "qemu" "rhel9" {
  qemu_binary = "/usr/libexec/qemu-kvm"
  qemuargs = [
    ["-display", "none"],
    ["-cpu", "host"]
  ]
  iso_url                = "../iso-files/rhel-baseos-9.0-x86_64-dvd.iso"
  iso_checksum           = "sha256:a387f3230acf87ee38707ee90d3c88f44d7bf579e6325492f562f0f1f9449e89"
  cd_files               = ["config/ks-el9.cfg"]
  cd_label               = "cidata"
  output_directory       = "builds"
  shutdown_command       = "echo 'packer' | sudo -S shutdown -P now"
  disk_size              = "20G"
  memory                 = "4096"
  cpus                   = "1"
  format                 = "qcow2"
  accelerator            = "kvm"
  ssh_password           = "vagrant"
  ssh_username           = "vagrant"
  ssh_timeout            = "20m"
  ssh_handshake_attempts = "15"
  headless               = true
  vm_name                = "packer-rhel-9-x86_64"
  net_device             = "virtio-net"
  disk_interface         = "virtio"
  boot_wait              = "15s"
  boot_command           = ["<up><wait><tab><wait> inst.text inst.ksstrict inst.ks=cdrom:/dev/sr1:/ks-el9.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.rhel9"]
}
