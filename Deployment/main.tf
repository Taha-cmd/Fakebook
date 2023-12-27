terraform {
  required_version = "1.6.3"

  backend "local" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.83"
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

}
