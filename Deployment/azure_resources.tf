data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  name     = "${var.unique_prefix}-rg"
  location = var.location
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "${var.unique_prefix}-app-identity"
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
}

