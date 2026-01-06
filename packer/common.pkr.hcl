packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = ">= 1.0.0"
    }
  }
}

variable "iso_path" {
  type        = string
  description = "Path to the RHEL ISO (absolute or relative to packer/)."
}

variable "iso_checksum" {
  type        = string
  description = "SHA256 checksum for the ISO, prefixed with 'sha256:'."
}

variable "iso_label" {
  type        = string
  description = "ISO volume label used by Anaconda (needed for inst.stage2 when set)."
  default     = ""
}

variable "artifacts_dir" {
  type        = string
  description = "Directory for logs, manifests, and build artifacts (absolute or relative to repo root)."
  default     = "artifacts/packer"
}

variable "ssh_timeout" {
  type        = string
  description = "Total time to wait for SSH to become available."
  default     = "15m"
}

variable "ssh_handshake_attempts" {
  type        = number
  description = "Number of SSH handshake attempts before failing."
  default     = 20
}

variable "breakpoint_enabled" {
  type        = bool
  description = "Pause before provisioning for interactive inspection."
  default     = false
}

variable "disk_size" {
  type        = string
  description = "Disk size for the image."
  default     = "20G"
}

variable "memory" {
  type        = string
  description = "Memory size for the VM (in MB)."
  default     = "2048"
}

variable "cpus" {
  type        = string
  description = "Number of vCPUs."
  default     = "2"
}

variable "boot_wait" {
  type        = string
  description = "Time to wait before sending boot commands."
  default     = "15s"
}

variable "boot_key_interval" {
  type        = string
  description = "Delay between keystrokes for boot commands."
  default     = "100ms"
}

variable "ssh_username" {
  type        = string
  description = "SSH username used by Packer."
  default     = "cloud-user"
}

variable "ssh_password" {
  type        = string
  description = "SSH password used by Packer (use PACKER_VAR_ssh_password to override)."
  default     = "cloud-user"
}

variable "shutdown_command" {
  type        = string
  description = "Shutdown command used by Packer."
  default     = "echo 'packer' | sudo -S shutdown -P now"
}

locals {
  iso_path_resolved      = can(regex("^/", var.iso_path)) ? var.iso_path : "${path.root}/${var.iso_path}"
  artifacts_dir_resolved = can(regex("^/", var.artifacts_dir)) ? var.artifacts_dir : "${path.root}/../${var.artifacts_dir}"
}
