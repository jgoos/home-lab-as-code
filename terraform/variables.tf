variable "vms" {
  description = "Virtual Machines"
  type        = map(any)
}

variable "ssh_public_key" {
  default = "id_ed25519.pub"
  type    = string
}

variable "cloud_user" {
  default = "cloud-user"
  type    = string
}

variable "local_domain" {
  default = "home.arpa"
  type    = string
}
