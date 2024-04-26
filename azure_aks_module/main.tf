locals {
  name               = "example"
  location           = "westeurope"
  kubernetes_version = "1.27"
  vm_size            = "Standard_B2s"
  node_count         = 1
}

resource "azurerm_resource_group" "example" {
  name     = "aks-example"
  location = local.location
}

module "aks" {
  source              = "./modules/aks_k8s"
  name                = local.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  kubernetes_version  = local.kubernetes_version
  vm_size             = local.vm_size
  node_count          = local.node_count
}


output "azurerm_kubernetes_cluster" {
  value     = module.aks.azurerm_kubernetes_cluster
  sensitive = true
}

output "kubeconfig" {
  value     = module.aks.kubeconfig
  sensitive = true
}

output "k8s_host" {
  value     = module.aks.k8s_host
  sensitive = true
}

output "k8s_client_certificate" {
  value     = module.aks.k8s_client_certificate
  sensitive = true
}

output "k8s_client_key" {
  value     = module.aks.k8s_client_key
  sensitive = true
}

output "k8s_cluster_ca_certificate" {
  value     = module.aks.k8s_cluster_ca_certificate
  sensitive = true
}
