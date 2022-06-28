variable "rhel_version" {
  description = "RHEL major version"
  default     = "8"
  type        = string
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

variable "vms" {
  description = "Virtual Machines"
  type        = map(any)
  default = {
    tower385 = {
      storage = "20"
      memory  = "2048"
      cpu     = "1"
      rhel_version = "9"
      group = "ansible_servers"
    }
    image-builder = {
      storage = "20"
      memory  = "2048"
      cpu     = "1"
      rhel_version = "8"
      group = "image_servers"
    }
    system1 = {
      storage = "20"
      memory  = "2048"
      cpu     = "1"
      rhel_version = "8"
      group = "image_servers"
    }
  }
}
