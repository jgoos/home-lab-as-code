source "qemu" "rhel9" {
  qemu_binary = "/usr/libexec/qemu-kvm"
  qemuargs = [
    ["-display", "none"],
    ["-cpu", "host"]
  ]
  iso_url                = "iso-files/rhel-baseos-9.0-x86_64-dvd.iso"
  iso_checksum           = "sha256:a387f3230acf87ee38707ee90d3c88f44d7bf579e6325492f562f0f1f9449e89"
  cd_label               = "CIDATA"
  cd_files               = ["config/ks-el9.cfg", "config/cloud.cfg"]
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
  vm_name                = "packer-rhel-9-x86_64"
  net_device             = "virtio-net"
  disk_interface         = "virtio"
  boot_wait              = "15s"
  boot_command           = ["<up><wait><tab><wait> inst.text inst.ksstrict inst.ks=cdrom:/dev/sr1:/ks-el9.cfg<enter><wait>"]
}

build {
  sources = ["source.qemu.rhel9"]
  post-processor "shell-local" {
    inline = ["virt-sysprep -a output-rhel9/packer-rhel-9-x86_64 --operations all,-lvm-uuids,-user-account,-firewall-rules,-fs-uuids,-flag-reconfiguration,-machine-id --scrub /etc/machine-id"]
  }
}
