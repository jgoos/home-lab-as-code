# Terraform

## Requirements

* [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)

## Variables

* Copy `terraform.tfvars.example` to `terraform.tfvars` (or another name that ends with .tfvars)
* Fill out your `terraform.tfvars` file
* Run `terraform init` to initialize the directory that contains a Terraform configuration
* Run `terraform plan -var-file=terraform.tfvars` to evaluate a Terraform configuration to determine the desired state
* Run `terraform apply -var-file=terraform.tfvars` to carry out the planned changes to each resource


> **note** | auto load the tfvars file without the `-var-file=terraform.tfvars` by putting `auto` in the name. For example: `terraform.auto.tfvars`

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_libvirt"></a> [libvirt](#requirement\_libvirt) | 0.6.14 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_libvirt"></a> [libvirt](#provider\_libvirt) | 0.6.14 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.2.3 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [libvirt_cloudinit_disk.commoninit](https://registry.terraform.io/providers/dmacvicar/libvirt/0.6.14/docs/resources/cloudinit_disk) | resource |
| [libvirt_domain.rhel](https://registry.terraform.io/providers/dmacvicar/libvirt/0.6.14/docs/resources/domain) | resource |
| [libvirt_volume.rhel](https://registry.terraform.io/providers/dmacvicar/libvirt/0.6.14/docs/resources/volume) | resource |
| [libvirt_volume.worker](https://registry.terraform.io/providers/dmacvicar/libvirt/0.6.14/docs/resources/volume) | resource |
| [local_file.ansible_config_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [local_file.ansible_inventory_file](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloud_user"></a> [cloud\_user](#input\_cloud\_user) | n/a | `string` | `"cloud-user"` | no |
| <a name="input_local_domain"></a> [local\_domain](#input\_local\_domain) | n/a | `string` | `"home.arpa"` | no |
| <a name="input_ssh_public_key"></a> [ssh\_public\_key](#input\_ssh\_public\_key) | n/a | `string` | `"id_ed25519.pub"` | no |
| <a name="input_vms"></a> [vms](#input\_vms) | Virtual Machines | `map(any)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
