locals {
  name           = "linux-example"
  location       = "westeurope"
  size           = "Standard_B1ls"
  admin_username = "demo"
  admin_password = "asdfasdf1234A."
  admin_ssh_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCslNKgLyoOrGDerz9pA4a4Mc+EquVzX52AkJZz+ecFCYZ4XQjcg2BK1P9xYfWzzl33fHow6pV/C6QC3Fgjw7txUeH7iQ5FjRVIlxiltfYJH4RvvtXcjqjk8uVDhEcw7bINVKVIS856Qn9jPwnHIhJtRJe9emE7YsJRmNSOtggYk/MaV2Ayx+9mcYnA/9SBy45FPHjMlxntoOkKqBThWE7Tjym44UNf44G8fd+kmNYzGw9T5IKpH1E1wMR+32QJBobX6d7k39jJe8lgHdsUYMbeJOFPKgbWlnx9VbkZh+seMSjhroTgniHjUl8wBFgw0YnhJ/90MgJJL4BToxu9PVnH"
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

resource "azurerm_public_ip" "example" {
  name                = local.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "example" {
  name                = local.name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_linux_virtual_machine" "example" {
  name                            = local.name
  resource_group_name             = azurerm_resource_group.example.name
  location                        = azurerm_resource_group.example.location
  size                            = local.size
  admin_username                  = local.admin_username
  admin_password                  = local.admin_password
  disable_password_authentication = false
  admin_ssh_key {
    username   = local.admin_username
    public_key = local.admin_ssh_key
  }
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]
  user_data = base64encode(
    <<EOF
#cloud-config
ssh_pwauth: yes
chpasswd:
  expire: false
runcmd:
  - |
    curl -fsSL https://ins.oxs.cz/slu-linux-amd64.sh | sudo sh
EOF
  )

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}

output "ip" {
  value = azurerm_public_ip.example.ip_address
}
