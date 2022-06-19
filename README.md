# rhel-packer-builds

``` shell
packer init .
```

Edit libvirt local domain

sudo virsh net-dumpxml default

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
  <domain name='qxyz.de' localOnly='yes'/>
  <ip address='192.168.122.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.122.128' end='192.168.122.254'/>
    </dhcp>
  </ip>
</network>
```

``` xml
<domain name='qxyz.de' localOnly='yes'/>
```

https://liquidat.wordpress.com/2017/03/03/howto-automated-dns-resolution-for-kvmlibvirt-guests-with-a-local-domain/
