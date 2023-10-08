locals {
  location  = "westeurope"
  zone_name = "${var.subdomain}.${var.domain}"
  rg_name   = replace(local.zone_name, ".", "-")
}

variable "domain" {}
variable "subdomain" {}

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = local.location
}

resource "azurerm_dns_zone" "main" {
  resource_group_name = azurerm_resource_group.main.name
  name                = local.zone_name
}

data "cloudflare_zone" "main" {
  name = var.domain
}

resource "cloudflare_record" "ns" {
  count = 4

  zone_id = data.cloudflare_zone.main.id
  name    = var.subdomain
  value   = sort(tolist(azurerm_dns_zone.main.name_servers))[count.index]
  type    = "NS"
  ttl     = 1
}

resource "azurerm_dns_a_record" "example" {
  name                = "example"
  zone_name           = azurerm_dns_zone.main.name
  resource_group_name = azurerm_resource_group.main.name
  ttl                 = 300
  records             = ["1.1.1.1"]
}

output "zone_name" {
  value = azurerm_dns_zone.main.name
}

output "example_record" {
  value = azurerm_dns_a_record.example.fqdn
}
