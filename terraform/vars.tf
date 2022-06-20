variable "rhel_version" {
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

variable "vm" {
  description = "Virtual Machines"
  type        = map(any)
  default = {
    controlnode1 = {
      hostname = "controlnode1"
      storage  = "40"
      memory   = "16384"
      cpu      = "4"
    }
    controlnode2 = {
      hostname = "controlnode2"
      storage  = "40"
      memory   = "16384"
      cpu      = "4"
    }
    execnode1 = {
      hostname = "execnode1"
      storage  = "40"
      memory   = "16384"
      cpu      = "4"
    }
    execnode2 = {
      hostname = "execnode2"
      storage  = "40"
      memory   = "16384"
      cpu      = "4"
    }
    databasenode = {
      hostname = "databasenode"
      storage  = "40"
      memory   = "16384"
      cpu      = "4"
    }
  }
}
