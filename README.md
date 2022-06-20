# Home Lab As Code

The code in this repository will:
- generate [`cloud-init`](https://cloud-init.io/) ready rhel images for rhel8 and rhel9 (or other rhel based distributions).
- automates the provisioning of virtual machines via terraform.
- the vm's are resolvable via dns from the local machine.

> Tested on `Red Hat Enterprise Linux release 9.0 (Plow)`

## Generate and download content
### Download ISO files
Download the needed rhel iso files and put them in the `iso-files` directory.  
(check the rhel8.pkr.hcl and rhel9.pkr.hcl packer config files what iso files are needed).

### Build packer images

``` bash
$ cd packer/<rhel_version>
$ packer init .
```

``` shell
$ cd packer/<rhel_version>
$ packer build .
```

## Configure libvirt

The libvirt configuration is based on the following instructions: [howto-automated-dns-resolution-for-kvmlibvirt-guests-with-a-local-domain](https://liquidat.wordpress.com/2017/03/03/howto-automated-dns-resolution-for-kvmlibvirt-guests-with-a-local-domain/).  
This configuration uses `home.arpa` for the domain name. (see [rfc8375](https://datatracker.ietf.org/doc/html/rfc8375)).

### Edit libvirt local domain

Check the current network configuration of the default network.

``` shell
$ sudo virsh net-dumpxml default
```

``` xml
<network connections='1'>
  <name>default</name>
  <uuid>158880c3-9adb-4a44-ab51-d0bc1c18cddc</uuid>
  <forward mode='nat'>
    <nat>
      <port start='1024' end='65535'/>
    </nat>
  </forward>
  <bridge name='virbr0' stp='on' delay='0'/>
  <mac address='52:54:00:fa:cb:e5'/>
  <domain name='home.arpa' localOnly='yes'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.128' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
```

Make sure this contains the following configuration:

``` xml
<domain name='home.arpa' localOnly='yes'/>
```

Configure via:

``` shell
virsh net-edit default
```

### Configure dns masquerading

``` shell
$ cat /etc/NetworkManager/conf.d/localdns.conf 
[main]
dns=dnsmasq
```

``` shell
$ cat /etc/NetworkManager/dnsmasq.d/libvirt_dnsmasq.conf
server=/home.arpa/192.168.123.1
```

``` shell
sudo systemctl restart NetworkManager
```

## Configure terraform
Configure the required virtual machines in `vars.tf`.

``` shell
$ terraform plan
$ terraform apply
```
