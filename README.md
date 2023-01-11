# Home Lab As Code

This repository provides a way to easily create and manage virtual machines on your local machine. It uses [Packer](https://www.packer.io/) to generate `cloud-init` ready Red Hat Enterprise Linux (RHEL) images, and [Terraform](https://www.terraform.io/) to automate the provisioning of virtual machines. The included dnsmasq configuration makes the virtual machines resolvable from the local machine using the `home.arpa` domain.

## Prerequisites

- Have [packer](https://www.packer.io/) installed on your system
- Have [terraform](https://www.terraform.io/) installed on your system
- Red Hat Enterprise Linux (RHEL) based distribution

## Downloading Content

### Download ISO files

To create the RHEL images, you'll need to download the appropriate ISO files and place them in the `packer/iso-files` directory. Check the `rhel8.pkr.hcl` and `rhel9.pkr.hcl` packer config files to see which ISO files are needed.

### Building Packer Images

To build the Packer images, follow these steps:

``` bash
cd packer/<rhel_version> 
packer init . 
packer build .
```

## Configuring libvirt

The libvirt configuration is based on the following instructions:  
[howto-automated-dns-resolution-for-kvmlibvirt-guests-with-a-local-domain](https://liquidat.wordpress.com/2017/03/03/howto-automated-dns-resolution-for-kvmlibvirt-guests-with-a-local-domain/).  
This configuration uses `home.arpa` for the domain name. (see [rfc8375](https://datatracker.ietf.org/doc/html/rfc8375)).

### Edit libvirt Local Domain

You'll need to configure the default libvirt network to use the `home.arpa` domain. To check the current network configuration, run the following command:

``` bash
sudo virsh net-dumpxml default
```

Example output:

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

Make sure the network configuration contains the following:

``` xml
<domain name='home.arpa' localOnly='yes'/>
```

If it's not, you can edit the configuration by running the following command:

``` bash
virsh net-edit default
```

### Configuring dns masquerading

To enable DNS masquerading, you'll need to make a few changes to your system's DNS settings. First, add the following line to `/etc/NetworkManager/conf.d/localdns.conf`:

``` ini
[main]
dns=dnsmasq
```

Then, add the following line to `/etc/NetworkManager/dnsmasq.d/libvirt_dnsmasq.conf`:

``` ini
server=/home.arpa/192.168.122.1
```

Finally, restart the NetworkManager service:

``` bash
sudo systemctl restart NetworkManager
```

## Configuring and Using Terraform

To use Terraform to manage your virtual machines, you'll need to perform a few additional steps:

- Install terraform on your system
- Configure the required virtual machines and their sizes in the `terraform/variables.tf` file
- Configure the virtual machines' network settings, such as IP addresses or hostnames, in the terraform configuration file.

### Initializing Terraform

To set up Terraform for use with this repository, run the following commands:

``` bash
cd terraform
terraform init
```

### Planning Terraform

To see what changes Terraform will make to your infrastructure, run:

``` bash
terraform plan
```

### Applying Terraform

To apply the changes, use the following command:

``` bash
terraform apply
```

### Modifying Infrastructure

To make changes to the existing infrastructure, edit the `terraform/main.tf` file and then run the `terraform apply` command again.

### Destroying Infrastructure

To destroy the infrastructure, run:

``` bash
terraform destroy
```

### Checking the current state of the infrastructure

To check the current state of the infrastructure run:

``` bash
terraform show
```

## Troubleshooting

In case of issues or errors, check the following:

- Make sure the appropriate versions of packer and terraform are installed.
- Check that the ISO files are in the correct directory and that the paths in the packer config files are correct.
- Verify that the NetworkManager service is running and properly configured.

## Additional Resources

- [Packer documentation](https://www.packer.io/docs)
- [Terraform documentation](https://www.terraform.io/docs/)
- [libvirt documentation](https://libvirt.org/docs.html)

Please note that some commands and file paths may be different depending on your operating system and specific setup.
