variable "vms" {
  description = "Virtual Machines"
  type = map(object({
    storage      = number
    memory       = number
    cpu          = number
    rhel_version = string
    group        = optional(string)
  }))
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

variable "packer_output_dir" {
  description = "Path (relative to terraform/) where Packer images are stored."
  type        = string
  default     = "../artifacts/packer"
}
