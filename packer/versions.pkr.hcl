# Plugin requirements shared by every rhel*.pkr.hcl template in this directory.
#
# Packer 1.10 removed the builders that used to ship inside the binary, so
# `source "qemu"` now resolves to an external plugin that has to be declared
# before it can be installed. Without this block `packer init` has nothing to
# fetch and a build fails with "unknown builder type: qemu".
#
# Packer merges every .pkr.hcl file in a directory, so this block applies to all
# templates as long as the build target is the directory. Build with
# `packer build -only=qemu.rhel9 .` rather than naming a single file, which
# would load that file alone and miss these requirements.

packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1.0"
    }
  }
}
