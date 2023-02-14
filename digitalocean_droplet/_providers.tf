terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
    }
  }
}

variable "digitalocean_token" {}
provider "digitalocean" {
  token = var.digitalocean_token
}
