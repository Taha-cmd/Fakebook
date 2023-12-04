resource "azurerm_postgresql_flexible_server" "this" {
  name                = "${var.unique_prefix}-pg-server"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  sku_name   = "B_Standard_B1ms" # 1 vCore
  storage_mb = 32768             # 32GB

  version = "15"

  authentication {
    active_directory_auth_enabled = true
    password_auth_enabled         = false
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }

  zone = "1"
}

resource "azurerm_postgresql_flexible_server_database" "this" {
  name      = "${var.unique_prefix}-pg-db"
  server_id = azurerm_postgresql_flexible_server.this.id
}

resource "azurerm_postgresql_flexible_server_active_directory_administrator" "this" {
  server_name         = azurerm_postgresql_flexible_server.this.name
  resource_group_name = azurerm_resource_group.this.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = data.azurerm_client_config.current.object_id
  principal_name      = data.azurerm_client_config.current.client_id
  principal_type      = "User"
}

resource "azurerm_postgresql_flexible_server_firewall_rule" "public_access" {
  name             = "AllowAll"
  server_id        = azurerm_postgresql_flexible_server.this.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_app_configuration_key" "postgres_config_values" {
  for_each = {
    PG_HOST     = azurerm_postgresql_flexible_server.this.fqdn
    PG_DATABASE = azurerm_postgresql_flexible_server_database.this.name
    PG_USER     = azurerm_user_assigned_identity.app.client_id
  }

  depends_on             = [azurerm_role_assignment.config_store_data_owner]
  configuration_store_id = azurerm_app_configuration.this.id

  locked = true
  key    = each.key
  value  = each.value
}
