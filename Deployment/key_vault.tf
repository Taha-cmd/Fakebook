resource "azurerm_key_vault" "this" {
  name                = "${var.unique_prefix}-key-vault"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location

  sku_name  = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id

  enable_rbac_authorization     = true
  public_network_access_enabled = true
}

# Key Vault RBAC roles: https://learn.microsoft.com/en-us/azure/key-vault/general/rbac-guide?tabs=azure-cli#azure-built-in-roles-for-key-vault-data-plane-operations
resource "azurerm_role_assignment" "secrets_reader" {
  role_definition_name = "Key Vault Secrets User"

  principal_id = azurerm_user_assigned_identity.app.principal_id
  scope        = azurerm_key_vault.this.id

  # See https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment#skip_service_principal_aad_check
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "key_vault_admin" {
  role_definition_name = "Key Vault Administrator"

  principal_id = data.azurerm_client_config.current.object_id
  scope        = azurerm_key_vault.this.id
}
