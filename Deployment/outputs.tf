output "vault_url" {
  value = azurerm_key_vault.this.vault_uri
}

output "config_store_url" {
  value = azurerm_app_configuration.this.endpoint
}

output "app_fqdn" {
  value = azurerm_container_group.app.fqdn
}
