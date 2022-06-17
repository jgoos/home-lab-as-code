variable "workers_count" {
  default = "3"
}

locals {
  vms = {
    execnode1 = {
      subnet = "west"
      systemdisk = "10"
    }
    controlnode1 = {
      subnet = "west"
      systemdisk = "10"
    }
    databasenode = {
      subnet = "east"
      systemdisk = "10"
    }
  }
}
