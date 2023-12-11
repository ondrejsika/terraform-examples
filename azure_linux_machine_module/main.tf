locals {
  name           = "linux-example"
  location       = "westeurope"
  size           = "Standard_B1ls"
  admin_username = "default"
  admin_password = "asdfasdf1234A."
  admin_ssh_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCslNKgLyoOrGDerz9pA4a4Mc+EquVzX52AkJZz+ecFCYZ4XQjcg2BK1P9xYfWzzl33fHow6pV/C6QC3Fgjw7txUeH7iQ5FjRVIlxiltfYJH4RvvtXcjqjk8uVDhEcw7bINVKVIS856Qn9jPwnHIhJtRJe9emE7YsJRmNSOtggYk/MaV2Ayx+9mcYnA/9SBy45FPHjMlxntoOkKqBThWE7Tjym44UNf44G8fd+kmNYzGw9T5IKpH1E1wMR+32QJBobX6d7k39jJe8lgHdsUYMbeJOFPKgbWlnx9VbkZh+seMSjhroTgniHjUl8wBFgw0YnhJ/90MgJJL4BToxu9PVnH"
  user_data = base64encode(
    <<EOF
#cloud-config
runcmd:
  - 'curl -fsSL https://ins.oxs.cz/slu-linux-amd64.sh | sudo sh'
EOF
  )
}

resource "azurerm_resource_group" "example" {
  name     = local.name
  location = local.location
}

resource "azurerm_virtual_network" "example" {
  name                = local.name
  address_space       = ["10.250.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.250.0.0/24"]
}

module "vm" {
  source = "./modules/vm"

  name                = local.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  subnet_id           = azurerm_subnet.example.id
  size                = local.size
  admin_username      = local.admin_username
  admin_password      = local.admin_password
  admin_ssh_key       = local.admin_ssh_key
  user_data           = local.user_data
}

output "ip" {
  value = module.vm.ip
}
