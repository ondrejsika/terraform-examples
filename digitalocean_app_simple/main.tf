resource "digitalocean_app" "example" {
  spec {
    name   = "iceland"
    region = "fra"

    service {
      name               = "iceand"
      instance_count     = 1
      instance_size_slug = "apps-s-1vcpu-0.5gb"
      http_port          = 80
      image {
        registry_type = "GHCR"
        registry      = "ghcr.io"
        repository    = "ondrejsika/iceland-5"
        tag           = "latest"
      }
    }

    ingress {
      rule {
        component {
          name = "iceand"
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
