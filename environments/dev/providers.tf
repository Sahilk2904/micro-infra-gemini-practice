terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "fa0b58e1-510e-484f-bda3-8cb2550c3aef"
  features {}
}
