
resource "digitalocean_loadbalancer" "example" {
  name   = "example"
  region = local.region

  enable_proxy_protocol = true

  droplet_tag = "k8s:${digitalocean_kubernetes_cluster.example.id}"

  healthcheck {
    port     = 80
    protocol = "tcp"
  }

  forwarding_rule {
    entry_port      = 80
    target_port     = 80
    entry_protocol  = "tcp"
    target_protocol = "tcp"
  }

  forwarding_rule {
    entry_port      = 443
    target_port     = 443
    entry_protocol  = "tcp"
    target_protocol = "tcp"
  }
}

output "lb_ip" {
  value = digitalocean_loadbalancer.example.ip
}

output "kubeconfig" {
  value     = digitalocean_kubernetes_cluster.example.kube_config.0.raw_config
  sensitive = true
}
