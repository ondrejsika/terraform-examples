resource "azurerm_resource_group" "example" {
  name     = "example-postgres"
  location = "westeurope"
}

resource "azurerm_postgresql_server" "example" {
  name                = "example-postgres"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  administrator_login          = "pgadmin"
  administrator_login_password = "omep_d86D_553j_ETBr"

  sku_name   = "B_Gen5_1"
  version    = "11"
  storage_mb = 5120

  backup_retention_days        = 7
  geo_redundant_backup_enabled = false
  auto_grow_enabled            = false

  public_network_access_enabled = true

  ssl_enforcement_enabled          = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
  # ssl_enforcement_enabled          = true
  # ssl_minimal_tls_version_enforced = "TLS1_2"
}

resource "azurerm_postgresql_firewall_rule" "example" {
  name                = "example"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}

resource "azurerm_postgresql_database" "example" {
  name                = "example"
  resource_group_name = azurerm_resource_group.example.name
  server_name         = azurerm_postgresql_server.example.name
  charset             = "UTF8"
  collation           = "en-US"
}

output "psql_command" {
  value = nonsensitive("psql 'host=${azurerm_postgresql_server.example.fqdn} port=5432 user=pgadmin@${azurerm_postgresql_server.example.name} password=${azurerm_postgresql_server.example.administrator_login_password} dbname=example'")
}

output "slu_postgres_ping_command" {
  value = nonsensitive("slu postgres ping -H ${azurerm_postgresql_server.example.fqdn} -P 5432 -u pgadmin@${azurerm_postgresql_server.example.name} -p ${azurerm_postgresql_server.example.administrator_login_password} -n example")
}
