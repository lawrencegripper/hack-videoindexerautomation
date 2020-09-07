terraform {
  required_version = ">= 0.13"
  required_providers {
    shell = {
      source  = "scottwinkler/shell"
      version = "=1.7.3"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.26"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "=1.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}
