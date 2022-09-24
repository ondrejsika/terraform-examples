locals {
  sikademo_com_zone_id = "f2c00168a7ecd694bb1ba017b332c019"
}

resource "cloudflare_record" "example" {
  zone_id = local.sikademo_com_zone_id
  name    = "cloudflare-record-example"
  value   = "53.53.53.53"
  type    = "A"
  proxied = false
}

output "fqdn" {
  value = cloudflare_record.example.hostname
}
