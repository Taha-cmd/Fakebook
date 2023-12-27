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
    PG_USER     = azurerm_user_assigned_identity.app.name
  }

  depends_on             = [azurerm_role_assignment.config_store_data_owner]
  configuration_store_id = azurerm_app_configuration.this.id

  locked = true # Make it readonly
  key    = each.key
  value  = each.value
}

# Enable workload identity in postgres:
# https://learn.microsoft.com/en-us/azure/postgresql/single-server/how-to-connect-with-managed-identity#creating-a-postgresql-user-for-your-managed-identity
resource "terraform_data" "create_pg_user" {
  depends_on = [
    azurerm_postgresql_flexible_server.this,
    azurerm_postgresql_flexible_server_database.this,
    azurerm_postgresql_flexible_server_active_directory_administrator.this,
    azurerm_postgresql_flexible_server_firewall_rule.public_access
  ]

  triggers_replace = {
    identity = azurerm_user_assigned_identity.app.client_id
    server   = azurerm_postgresql_flexible_server.this.id
    database = azurerm_postgresql_flexible_server_database.this.id
  }

  provisioner "local-exec" {
    interpreter = ["pwsh", "-Command"]

    environment = {
      "PGHOST" = azurerm_postgresql_flexible_server.this.fqdn
      "PGUSER" = data.azurerm_client_config.current.client_id

      "IDENTITY_NAME"   = azurerm_user_assigned_identity.app.name
      "TARGET_DATABASE" = azurerm_postgresql_flexible_server_database.this.name
    }

    # https://github.com/MicrosoftDocs/azure-docs/issues/102693#issuecomment-1668488887
    # https://stackoverflow.com/a/77289725

    # TODO: test this in greenfield again
    # Quoting hell:
    # database names with hyphens must be quoted
    # double quotes must be escaped with ` in powershell and with \ for postgres
    command = <<EOT
      $env:PGPASSWORD = az account get-access-token --resource-type oss-rdbms --output tsv --query accessToken

      # Create a user for the app in the root database. See # https://github.com/MicrosoftDocs/azure-docs/issues/102693#issuecomment-1798118261
      psql --dbname "postgres" --no-password --command "SELECT * FROM pgaadauth_create_principal('$($env:IDENTITY_NAME)', false, false);"

      # Connect to the app's database as admin and grant the user all permissions to the database
      psql --dbname "$($env:TARGET_DATABASE)" --no-password --command "GRANT ALL ON SCHEMA public TO \`"$($env:IDENTITY_NAME)\`";"

    EOT
  }
}
