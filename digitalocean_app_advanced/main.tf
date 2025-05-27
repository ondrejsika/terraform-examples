resource "digitalocean_app" "example" {
  spec {
    name   = "hello-world"
    region = "fra"

    service {
      name           = "hello-world"
      instance_count = 2
      # instance_size_slug = "apps-s-1vcpu-0.5gb"
      http_port = 8000
      image {
        registry_type = "GHCR"
        registry      = "ghcr.io"
        repository    = "sikalabs/hello-world-server"
        tag           = "latest"
      }
      env {
        type  = "GENERAL"
        key   = "TEXT"
        value = "Hello from DigitalOcean App Platform!"
      }
      env {
        type  = "GENERAL"
        key   = "COLOR"
        value = "#0280FF"
      }
    }

    ingress {
      rule {
        component {
          name = "hello-world"
        }
        match {
          path {
            prefix = "/"
          }
        }
      }
    }
  }
}

output "live_domain" {
  value = digitalocean_app.example.live_domain
}

output "live_url" {
  value = digitalocean_app.example.live_url
}
