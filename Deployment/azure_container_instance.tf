resource "azurerm_container_group" "app" {
  resource_group_name = azurerm_resource_group.this.name
  location            = var.location
  name                = "${var.unique_prefix}-app"

  os_type = "Linux"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  dns_name_label  = var.unique_prefix
  ip_address_type = "Public"
  restart_policy  = "Always"

  container {
    cpu    = 1
    memory = 1 # 1Gb

    image = docker_image.app.name
    name  = "fakebook"

    ports {
      port     = local.app_port
      protocol = "TCP"
    }

    environment_variables = {
      "CONFIG_STORE_ENDPOINT" = azurerm_app_configuration.this.endpoint
      "KEY_VAULT_ENDPOINT"    = azurerm_key_vault.this.vault_uri
      "ASPNETCORE_HTTP_PORTS" = local.app_port # https://learn.microsoft.com/en-us/dotnet/core/compatibility/containers/8.0/aspnet-port
    }
  }
}
