locals {
  rhel10_output_directory = "${local.artifacts_dir_resolved}/output-rhel10"
  rhel10_vm_name          = "packer-rhel-10-x86_64"
  rhel10_image_path       = "${local.rhel10_output_directory}/${local.rhel10_vm_name}"
  rhel10_serial_log       = "${local.artifacts_dir_resolved}/serial-rhel10.log"
  rhel10_manifest_path    = "${local.artifacts_dir_resolved}/manifest-rhel10.json"
}

source "qemu" "rhel10" {
  qemu_binary = "/usr/libexec/qemu-kvm"
  qemuargs = [
    ["-display", "none"],
    ["-cpu", "host"],
    ["-serial", "file:${local.rhel10_serial_log}"]
  ]
  iso_url                = local.iso_path_resolved
  iso_checksum           = var.iso_checksum
  cd_label               = "OEMDRV"
  cd_files               = ["${path.root}/config/ks-el10.cfg", "${path.root}/config/cloud.cfg"]
  communicator           = "ssh"
  shutdown_command       = var.shutdown_command
  disk_size              = var.disk_size
  memory                 = var.memory
  cpus                   = var.cpus
  format                 = "qcow2"
  accelerator            = "kvm"
  machine_type           = "q35"
  ssh_username           = var.ssh_username
  ssh_password           = var.ssh_password
  ssh_timeout            = var.ssh_timeout
  ssh_handshake_attempts = var.ssh_handshake_attempts
  headless               = true
  vm_name                = local.rhel10_vm_name
  output_directory       = local.rhel10_output_directory
  net_device             = "virtio-net"
  disk_interface         = "virtio"
  boot_wait              = var.boot_wait
  boot_key_interval      = var.boot_key_interval
  boot_command = [
    "<wait><esc><wait>",
    "c<wait>",
    "linux /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=${var.iso_label} inst.text inst.ks=hd:LABEL=OEMDRV:/ks-el10.cfg inst.ksstrict inst.loglevel=debug rd.multipath=0 rd.iscsi=0 rd.driver.blacklist=dm_multipath modprobe.blacklist=dm_multipath console=ttyS0,115200n8 earlycon=ttyS0,115200 loglevel=7 net.ifnames=0 biosdevname=0",
    "<enter><wait>",
    "initrd /images/pxeboot/initrd.img",
    "<enter><wait>",
    "boot",
    "<enter><wait>"
  ]
}

build {
  sources = ["source.qemu.rhel10"]

  provisioner "shell" {
    inline = [
      "sudo sed -i 's/^#\\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config",
      "sudo sed -i 's/^#\\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' /etc/ssh/sshd_config",
      "sudo sed -i 's/^#\\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config",
      "if grep -q '^disable_root:' /etc/cloud/cloud.cfg; then sudo sed -i 's/^disable_root:.*/disable_root: 1/' /etc/cloud/cloud.cfg; else echo 'disable_root: 1' | sudo tee -a /etc/cloud/cloud.cfg >/dev/null; fi",
      "if grep -q '^ssh_pwauth:' /etc/cloud/cloud.cfg; then sudo sed -i 's/^ssh_pwauth:.*/ssh_pwauth: 0/' /etc/cloud/cloud.cfg; else echo 'ssh_pwauth: 0' | sudo tee -a /etc/cloud/cloud.cfg >/dev/null; fi"
    ]
  }

  post-processor "shell-local" {
    inline = [
      "virt-sysprep -a ${local.rhel10_image_path} --operations defaults,-lvm-uuids --run-command '> /etc/machine-id'"
    ]
  }

  post-processor "manifest" {
    output     = local.rhel10_manifest_path
    strip_path = true
  }
}
