locals {
  location = "westeurope"
  name     = "az-ssh-example"

  vm_size           = "Standard_B1ls"
  vm_admin_username = "default"
  vm_admin_password = "asdfasdf1234A."
  vm_admin_ssh_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCslNKgLyoOrGDerz9pA4a4Mc+EquVzX52AkJZz+ecFCYZ4XQjcg2BK1P9xYfWzzl33fHow6pV/C6QC3Fgjw7txUeH7iQ5FjRVIlxiltfYJH4RvvtXcjqjk8uVDhEcw7bINVKVIS856Qn9jPwnHIhJtRJe9emE7YsJRmNSOtggYk/MaV2Ayx+9mcYnA/9SBy45FPHjMlxntoOkKqBThWE7Tjym44UNf44G8fd+kmNYzGw9T5IKpH1E1wMR+32QJBobX6d7k39jJe8lgHdsUYMbeJOFPKgbWlnx9VbkZh+seMSjhroTgniHjUl8wBFgw0YnhJ/90MgJJL4BToxu9PVnH"
  vm_user_data = base64encode(
    <<EOF
#cloud-config
ssh_pwauth: yes
chpasswd:
  expire: false
packages:
  - jq
runcmd:
  - sed -i 's|^SHELL=.*|SHELL=/bin/bash|' /etc/default/useradd
write_files:
  - path: /usr/local/bin/get_secret.sh
    permissions: '0755'
    content: |
      #!/bin/sh
      TOKEN=$(curl -sf 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://vault.azure.net' -H 'Metadata: true' | jq -r '.access_token')
      curl -sf "https://${local.keyvault_name}.vault.azure.net/secrets/${local.secret_name}?api-version=7.4" -H "Authorization: Bearer $TOKEN" | jq -r '.value'
EOF
  )

  # Key Vault name must be globally unique, 3-24 chars
  keyvault_name = "az-ssh-example-4356"
  secret_name   = "my-secret"
  secret_value  = "super-secret-value"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "example" {
  name     = local.name
  location = local.location
}

resource "azurerm_key_vault" "example" {
  name                = local.keyvault_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

# Grant Terraform SP access to manage secrets in the vault
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id       = azurerm_key_vault.example.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = data.azurerm_client_config.current.object_id
  secret_permissions = ["Backup", "Delete", "Get", "List", "Purge", "Recover", "Restore", "Set"]
}

resource "azurerm_key_vault_secret" "example" {
  name         = local.secret_name
  value        = local.secret_value
  key_vault_id = azurerm_key_vault.example.id
  depends_on   = [azurerm_key_vault_access_policy.terraform]
}

module "net" {
  source = "./net"

  name                = local.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = "10.250.0.0/16"
  subnet_prefix       = "10.250.0.0/24"
}

module "vm" {
  source = "./vm"

  name                = local.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  subnet_id           = module.net.subnet_id
  size                = local.vm_size
  admin_username      = local.vm_admin_username
  admin_password      = local.vm_admin_password
  admin_ssh_key       = local.vm_admin_ssh_key
  user_data           = local.vm_user_data
}

resource "azurerm_role_assignment" "vm_admin_login" {
  scope                = module.vm.id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Grant the VM's managed identity read access to secrets
resource "azurerm_key_vault_access_policy" "vm" {
  key_vault_id       = azurerm_key_vault.example.id
  tenant_id          = data.azurerm_client_config.current.tenant_id
  object_id          = module.vm.principal_id
  secret_permissions = ["Get", "List"]
}

output "ip" {
  value = module.vm.ip
}

output "keyvault_uri" {
  value = azurerm_key_vault.example.vault_uri
}

output "vm_principal_id" {
  value = module.vm.principal_id
}

output "ssh" {
  value = "az ssh vm --subscription ${data.azurerm_client_config.current.subscription_id} -g ${azurerm_resource_group.example.name} -n ${local.name}"
}
