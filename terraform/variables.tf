variable "rhel_version" {
  description = "RHEL major version"
  default = "9"
  type    = string
}

variable "ssh_public_key" {
  default = "id_ed25519.pub"
  type    = string
}

variable "cloud_user" {
  default = "ansible"
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
    controlnode1 = {
      hostname = "controlnode1"
      storage  = "20"
      memory   = "2048"
      cpu      = "1"
    }
    controlnode2 = {
      hostname = "controlnode2"
      storage  = "20"
      memory   = "2048"
      cpu      = "1"
    }
    execnode1 = {
      hostname = "execnode1"
      storage  = "20"
      memory   = "2048"
      cpu      = "1"
    }
    execnode2 = {
      hostname = "execnode2"
      storage  = "20"
      memory   = "2048"
      cpu      = "1"
    }
    databasenode = {
      hostname = "databasenode"
      storage  = "20"
      memory   = "2048"
      cpu      = "1"
    }
  }
}
