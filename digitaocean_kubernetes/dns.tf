resource "cloudflare_record" "lb" {
  zone_id = local.cloudflare_zone_id
  name    = "k8s-example"
  value   = digitalocean_loadbalancer.example.ip
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "lb_wildcard" {
  zone_id = local.cloudflare_zone_id
  name    = "*.${cloudflare_record.lb.name}"
  value   = cloudflare_record.lb.hostname
  type    = "CNAME"
  proxied = false
}
