terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
  }
}

variable "azurerm_tenant_id" {}
variable "azurerm_subscription_id" {}
variable "azurerm_client_id" {}
variable "azurerm_client_secret" {}

provider "azurerm" {
  features {}
  tenant_id       = var.azurerm_tenant_id
  subscription_id = var.azurerm_subscription_id
  client_id       = var.azurerm_client_id
  client_secret   = var.azurerm_client_secret
}

variable "cloudflare_api_token" {}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}
