output "output_from_run" {
  value = {
    for k, v in libvirt_domain.rhel : k => v.network_interface.0.addresses.0
  }
}
