locals {
  storage_account_name   = "example${random_string.suffix.result}"
  storage_container_name = "example"
  resource_group_name    = "storage-account-example"
  location               = "westeurope"
}

resource "random_string" "suffix" {
  length  = 10
  lower   = false
  upper   = false
  special = false
}


resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_storage_account" "example" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = local.storage_container_name
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "private"
}


output "storage_account_name" {
  value = local.storage_account_name
}

output "storage_container_name" {
  value = local.storage_container_name
}

output "primary_access_key" {
  value     = azurerm_storage_account.example.primary_access_key
  sensitive = true
}
