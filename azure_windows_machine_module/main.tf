locals {
  name           = "windows-example"
  location       = "westeurope"
  size           = "Standard_D2s_v3"
  admin_username = "demo"
  admin_password = "asdfasdf1234A."
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

module "vms" {
  for_each = {
    "0" = null
  }

  source = "./modules/win_vm"

  name                = "win${each.key}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = local.size
  admin_username      = local.admin_username
  admin_password      = local.admin_password
  subnet_id           = azurerm_subnet.example.id
}

output "win_vms" {
  value = module.vms
}
