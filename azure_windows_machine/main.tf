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

resource "azurerm_network_interface" "example" {
  name                = "${local.name}-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = local.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = local.size

  admin_username = local.admin_username
  admin_password = local.admin_password
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "win10-21h2-pro-g2"
    version   = "latest"
  }
}

output "ip" {
  value = azurerm_public_ip.example.ip_address
}
