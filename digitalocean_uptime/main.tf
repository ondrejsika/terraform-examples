resource "digitalocean_uptime_check" "example" {
  name   = "sika.io"
  target = "https://sika.io"
  regions = [
    "eu_west",
  ]
}

resource "digitalocean_uptime_alert" "example" {
  check_id   = digitalocean_uptime_check.example.id
  name       = "downtime"
  type       = "down"
  period     = "2m"
  comparison = "less_than"
  threshold  = 1
  notifications {
    email = [
      "ondrejsika@ondrejsika.com",
    ]
  }
}
