terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

variable "azurerm_subscription_id" {}

provider "azurerm" {
  features {}
  subscription_id = var.azurerm_subscription_id
}
