terraform {
  required_version = "1.6.3"

  backend "local" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.83"
    }

    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.21.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }

    key_vault {
      purge_soft_delete_on_destroy = true
    }

    app_configuration {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "docker" {

  registry_auth {
    address     = "docker.io"
    config_file = pathexpand("~/.docker/config.json")
  }
}

# https://registry.terraform.io/providers/cyrilgdn/postgresql/latest/docs#azure
# provider "postgresql" {
#   host                = azurerm_postgresql_flexible_server.this.fqdn
#   port                = "5432"
#   database            = "postgres"
#   username            = azurerm_postgresql_flexible_server_active_directory_administrator.this.principal_name
#   sslmode             = "require"
#   azure_identity_auth = true
#   azure_tenant_id     = azurerm_postgresql_flexible_server_active_directory_administrator.this.tenant_id
# }

