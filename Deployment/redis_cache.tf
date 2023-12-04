resource "azurerm_redis_cache" "this" {
  name                = "${var.unique_prefix}-redis-cache"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  # This is cheapest combination: ~ 16USD/M
  sku_name = "Basic"
  family   = "C"
  capacity = 0

  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_version = 6 # Version 4 is retired

  identity {
    type = "SystemAssigned"
  }

  redis_configuration {
    enable_authentication = true
    # active_directory_authentication_enabled = true # Only supported in Premium SKU
  }

  public_network_access_enabled = true
}

resource "azurerm_key_vault_secret" "redis_connection_string" {
  # Wait untill the client gets permissions to create secrets
  depends_on = [azurerm_role_assignment.key_vault_admin]

  name  = "redis-connection-string"
  value = azurerm_redis_cache.this.primary_connection_string

  key_vault_id = azurerm_key_vault.this.id
}
