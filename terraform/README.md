# rhel-packer-builds

``` shell
packer init .
```

cloud_init.cfg example:

``` 
#cloud-config
hostname: <hostname>
fqdn: <fqdn>
users:
  - name: <username>
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - <put ssh public key here>
```
