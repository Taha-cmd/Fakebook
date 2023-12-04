resource "azurerm_app_configuration" "this" {
  name                = "${var.unique_prefix}-config-store"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  local_auth_enabled    = false # Disable auth with connection strings and access keys
  public_network_access = "Enabled"

  sku = "free"

  identity {
    type = "SystemAssigned"
  }
}

# https://learn.microsoft.com/en-us/azure/azure-app-configuration/concept-enable-rbac#azure-built-in-roles-for-azure-app-configuration
resource "azurerm_role_assignment" "config_store_data_reader" {
  role_definition_name = "App Configuration Data Reader"

  principal_id = azurerm_user_assigned_identity.app.principal_id
  scope        = azurerm_app_configuration.this.id

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "config_store_data_owner" {
  role_definition_name = "App Configuration Data Owner"

  principal_id = data.azurerm_client_config.current.object_id
  scope        = azurerm_app_configuration.this.id
}
