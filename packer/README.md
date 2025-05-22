# Packer

## Requirements

steps:

  - install [packer](https://www.packer.io/)
  - `dnf install -y guestfs-tools`
  - download the required iso files

### Download iso files

Check `rhel.pkr.hcl` for what ISO files are needed.
Download and put these in the `iso-files` directory.

## Build packer images

``` shell
$ packer init .
```

To build all versions in parallel.

``` shell
$ packer build .
```

To build a specific version (e.g. RHEL 8).

``` shell
$ packer build -only=qemu.rhel.8 .
```
