# Packer

Install packer: https://www.packer.io/

## Download iso files

Check the `rhel<version>.pkr.hcl` packer files for what iso files are needed.
Download en put these in the iso-files directory.

## Build packer images

``` shell
$ packer init .
```

To build all versions in parralel.

``` shell
$ packer build .
```

To build specific version.

``` shell
$ packer build <template_name>
```
