locals {
  name               = "example"
  location           = "westeurope"
  kubernetes_version = "1.28"
  vm_size            = "Standard_B2s"
  node_count         = 1
}

resource "azurerm_resource_group" "example" {
  name     = "aks-example"
  location = local.location
}


resource "azurerm_kubernetes_cluster" "example" {
  name                              = local.name
  location                          = azurerm_resource_group.example.location
  resource_group_name               = azurerm_resource_group.example.name
  dns_prefix                        = local.name
  kubernetes_version                = local.kubernetes_version
  role_based_access_control_enabled = true

  default_node_pool {
    name       = local.name
    node_count = local.node_count
    vm_size    = local.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin    = "azure"
    service_cidr      = "10.43.0.0/16"
    dns_service_ip    = "10.43.0.10"
    load_balancer_sku = "standard"
  }
}

output "azurerm_kubernetes_cluster" {
  value     = azurerm_kubernetes_cluster.example
  sensitive = true
}

output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive = true
}

output "k8s_host" {
  value     = azurerm_kubernetes_cluster.example.kube_config[0].host
  sensitive = true
}

output "k8s_client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config[0].client_certificate
  sensitive = true
}

output "k8s_client_key" {
  value     = azurerm_kubernetes_cluster.example.kube_config[0].client_key
  sensitive = true
}

output "k8s_cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config[0].cluster_ca_certificate
  sensitive = true
}
