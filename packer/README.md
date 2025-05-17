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

``` shell
$ packer init .
```

To build all versions in parallel.

``` shell
$ packer build .
```

To build a specific version.

``` shell
$ packer build <template_name>
```
