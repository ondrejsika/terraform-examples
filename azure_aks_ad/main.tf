locals {
  resource_group_name = "example-aks-ad"
  name                = "example2"
  location            = "westeurope"
  kubernetes_version  = "1.28"
  vm_size             = "Standard_B2s"
  node_count          = 2
}

resource "azurerm_resource_group" "example" {
  name     = local.resource_group_name
  location = local.location
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
resource "azurerm_kubernetes_cluster" "example" {
  name                              = local.name
  location                          = azurerm_resource_group.example.location
  resource_group_name               = azurerm_resource_group.example.name
  dns_prefix                        = local.name
  kubernetes_version                = local.kubernetes_version
  role_based_access_control_enabled = true
  oidc_issuer_enabled               = true

  default_node_pool {
    name       = local.name
    node_count = local.node_count
    vm_size    = local.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  azure_active_directory_role_based_access_control {
    managed = true
    admin_group_object_ids = [
      "3673497d-1186-4942-8046-10ecd8acc14d",
    ]
    azure_rbac_enabled = false
    # - managed                = true -> null
  }

  key_vault_secrets_provider {
    # secret_identity = [
    #   {
    #     client_id                 = "85faad77-5cc5-478e-9461-af246ea5280b"
    #     object_id                 = "96094b7a-5764-4663-83df-b7984c9cf464"
    #     user_assigned_identity_id = "/subscriptions/5768238c-1ecd-49ab-83cc-b09bf70a7bff/resourcegroups/MC_aks-example_example_westeurope/providers/Microsoft.ManagedIdentity/userAssignedIdentities/azurekeyvaultsecretsprovider-example"
    #   }
    # ]
    secret_rotation_enabled  = false
    secret_rotation_interval = "2m"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.43.0.0/16"
    dns_service_ip = "10.43.0.10"
    # pod_cidr          = "10.42.0.1/16"
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
