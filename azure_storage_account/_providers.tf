terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}

variable "azurerm_client_id" {}
variable "azurerm_subscription_id" {}
variable "azurerm_tenant_id" {}
variable "azurerm_client_secret" {}


provider "azurerm" {
  features {}
  client_id       = var.azurerm_client_id
  subscription_id = var.azurerm_subscription_id
  tenant_id       = var.azurerm_tenant_id
  client_secret   = var.azurerm_client_secret
}
