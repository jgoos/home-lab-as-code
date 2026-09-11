# Packer

## Requirements

steps:

  - install [packer](https://www.packer.io/)
  - `dnf install -y guestfs-tools`
  - download the required iso files

### Download iso files

Check the `rhel<version>.pkr.hcl` packer files for what iso files are needed.
Download and put these in the iso-files directory.

## Build packer images

Install the plugins declared in `versions.pkr.hcl`. Run this once, and again
whenever the plugin requirements change.

``` shell
packer init .
```

Check the templates before spending twenty minutes on a build.

``` shell
packer validate .
```

To build all versions in parallel.

``` shell
packer build .
```

To build a specific version, filter by source name rather than naming the file.
Passing a single file loads that file alone, so Packer never reads the shared
`versions.pkr.hcl` and fails with `unknown builder type: qemu`.

``` shell
packer build -only='qemu.rhel9' .
```
