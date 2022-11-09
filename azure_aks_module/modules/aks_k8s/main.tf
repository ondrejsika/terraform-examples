terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}

variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "vm_size" {
  type = string
}

variable "node_count" {
  type = number
}

resource "azurerm_kubernetes_cluster" "example" {
  name                              = var.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.name
  kubernetes_version                = var.kubernetes_version
  role_based_access_control_enabled = true

  default_node_pool {
    name       = var.name
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin     = "azure"
    service_cidr       = "10.43.0.0/16"
    dns_service_ip     = "10.43.0.10"
    docker_bridge_cidr = "10.42.0.1/16"
    load_balancer_sku  = "standard"
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
