# Ansible

> **note:** The `inventory/hosts` and `ansible.cfg` are created and managed by terraform. On creation of a new virtual machine, the ssh finger print is removed from known_hosts.

## Collections

Install the needed ansible collections via:

``` shell
ansible-galaxy install -r collections/requirements.yml
```

## Vault

To protect sensitive variables.

### Create the vault file

`group_vars/all/vault.yml` with content:

``` yaml
vault_activationkey: <activation key name>
vault_org_id: <organization id>
```

### Encrypt the vault file

- Encrypt the vault file

``` shell
ansible-vault encrypt group_vars/all/vault.yml
New Vault password:
Confirm New Vault password:
Encryption successful
```

### Using

``` shell
ansible-playbook subscribe_system.yml --ask-vault-pass
```

### Red Hat subscription & activation keys

> **note:** Get a Red Hat developer subscription via: https://developers.redhat.com

Create an activation key. https://access.redhat.com/management/activation_keys
