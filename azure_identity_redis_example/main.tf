locals {
  location = "westeurope"
  name     = "identity-example-with-redis"

  vm_size           = "Standard_B1ls"
  vm_admin_username = "default"
  vm_admin_password = "asdfasdf1234A."
  vm_admin_ssh_key  = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCslNKgLyoOrGDerz9pA4a4Mc+EquVzX52AkJZz+ecFCYZ4XQjcg2BK1P9xYfWzzl33fHow6pV/C6QC3Fgjw7txUeH7iQ5FjRVIlxiltfYJH4RvvtXcjqjk8uVDhEcw7bINVKVIS856Qn9jPwnHIhJtRJe9emE7YsJRmNSOtggYk/MaV2Ayx+9mcYnA/9SBy45FPHjMlxntoOkKqBThWE7Tjym44UNf44G8fd+kmNYzGw9T5IKpH1E1wMR+32QJBobX6d7k39jJe8lgHdsUYMbeJOFPKgbWlnx9VbkZh+seMSjhroTgniHjUl8wBFgw0YnhJ/90MgJJL4BToxu9PVnH"
  vm_user_data = base64encode(
    <<EOF
#cloud-config
ssh_pwauth: yes
chpasswd:
  expire: false
packages:
  - redis-tools
  - jq
runcmd:
  - echo 'REDIS=${local.redis_host}' >> /etc/environment
write_files:
  - path: /usr/local/bin/redis_ping.sh
    permissions: '0755'
    content: |
      #!/bin/bash
      TOKEN=$(curl -sf 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://redis.azure.com' -H 'Metadata: true' | jq -r '.access_token')
      OID=$(echo "$TOKEN" | cut -d'.' -f2 | base64 -d 2>/dev/null | jq -r '.oid')
      redis-cli -h "$REDIS" -p 6379 --user "$OID" -a "$TOKEN" INCR counter
EOF
  )

  redis_name = "identity-example-4356"
  redis_host = "${local.redis_name}.redis.cache.windows.net"
}

resource "azurerm_resource_group" "example" {
  name     = local.name
  location = local.location
}

resource "azurerm_redis_cache" "example" {
  name                          = local.redis_name
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  capacity                      = 0
  family                        = "C"
  sku_name                      = "Basic"
  non_ssl_port_enabled          = true
  minimum_tls_version           = "1.2"
  redis_version                 = 6
  public_network_access_enabled = true

  redis_configuration {
    authentication_enabled                  = true
    active_directory_authentication_enabled = true
  }
}

resource "azurerm_redis_firewall_rule" "allow_all" {
  name                = "allow_all"
  redis_cache_name    = azurerm_redis_cache.example.name
  resource_group_name = azurerm_resource_group.example.name
  start_ip            = "0.0.0.0"
  end_ip              = "255.255.255.255"
}

resource "azurerm_redis_cache_access_policy_assignment" "vm" {
  name               = "vm-identity"
  redis_cache_id     = azurerm_redis_cache.example.id
  access_policy_name = "Data Contributor"
  object_id          = module.vm.principal_id
  object_id_alias    = local.name
}

module "net" {
  source = "./net"

  name                = local.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = "10.250.0.0/16"
  subnet_prefix       = "10.250.0.0/24"
}

module "vm" {
  source = "./vm"

  name                = local.name
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  subnet_id           = module.net.subnet_id
  size                = local.vm_size
  admin_username      = local.vm_admin_username
  admin_password      = local.vm_admin_password
  admin_ssh_key       = local.vm_admin_ssh_key
  user_data           = local.vm_user_data
}

output "ip" {
  value = module.vm.ip
}

output "ssh" {
  value = "ssh ${local.vm_admin_username}@${module.vm.ip}"
}

output "redis_hostname" {
  value = azurerm_redis_cache.example.hostname
}

output "vm_principal_id" {
  value = module.vm.principal_id
}
