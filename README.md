# Home Lab As Code

This repository provides a way to easily create and manage virtual machines on your local machine.
It uses [Packer](https://www.packer.io/) to generate `cloud-init` ready Red Hat Enterprise Linux (RHEL) images, and [Terraform](https://www.terraform.io/) to automate the provisioning of virtual machines.
The included dnsmasq configuration makes the virtual machines resolvable from the local machine using the `home.arpa` domain.
Additionally, after the provisioning process with Terraform, it will create an updated ansible inventory that can be used for further management and configuration of the provisioned machines.

## Prerequisites

- Have [ansible](https://www.ansible.com/) installed on your system
- Have [packer](https://www.packer.io/) installed on your system
- Have [terraform](https://www.terraform.io/) installed on your system
- Red Hat Enterprise Linux (RHEL) based distribution

## Downloading Content

### Download ISO files

To create the RHEL images, you'll need to download the appropriate ISO files and place them in the `packer/iso-files` directory. Check the `rhel8.pkr.hcl` and `rhel9.pkr.hcl` packer config files to see which ISO files are needed.

## Building Packer Images

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

## Configuring dns masquerading

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

## Using Terraform to deploy VMs

To deploy the VMs using the built images, navigate to the `terraform` directory and follow these steps:

### Variables

1. Copy `terraform.tfvars.example` to `terraform.tfvars` (or another name that ends with .tfvars)
2. Fill out your `terraform.tfvars` file
3. Run `terraform init` to initialize the directory that contains a Terraform configuration
4. Run `terraform plan -var-file=terraform.tfvars` to evaluate a Terraform configuration to determine the desired state
5. Run `terraform apply -var-file=terraform.tfvars` to carry out the planned changes to each resource

> **note**: you can auto load the tfvars file without the `-var-file=terraform.tfvars` by putting `auto` in the name. For example: `terraform.auto.tfvars`

## Using Ansible to provision VMs

The playbooks in the `ansible` directory can be used to provision the VMs deployed by terraform. You can use `ansible-playbook` command to run the playbooks.
During the terraform deployment a `ansible.cfg` is created containing the user that is specified in the [variables.tf](terrafrom/variables.tf) file. The default user is `cloud-user`.
Also the `ansible/inventory/hosts` is updated with the new information via terraform.

## Troubleshooting

In case of issues or errors, check the following:

- Make sure the appropriate versions of packer and terraform are installed.
- Check that the ISO files are in the correct directory and that the paths in the packer config files are correct.
- Verify that the NetworkManager service is running and properly configured.

## Additional Resources

- [Ansible documentation](https://docs.ansible.com/)
- [Packer documentation](https://www.packer.io/docs)
- [Terraform documentation](https://www.terraform.io/docs/)
- [Libvirt documentation](https://libvirt.org/docs.html)

Please note that some commands and file paths may be different depending on your operating system and specific setup.

## Licensing

This repository is licensed under the MIT license. Refer to the [LICENSE](LICENSE) file for details.

This project can serve as a great starting point for automating your home lab infrastructure and can be easily customized to suit your specific needs.
