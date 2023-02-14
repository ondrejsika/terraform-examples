resource "digitalocean_kubernetes_cluster" "example" {
  name   = "example"
  region = local.region
  // Get available versions using: doctl kubernetes options versions
  version = local.k8s_version

  node_pool {
    name       = "example"
    size       = local.node_size
    node_count = local.node_count
  }
}
