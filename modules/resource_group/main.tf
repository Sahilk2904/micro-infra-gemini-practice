terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

resource "azurerm_resource_group" "this" {
  for_each = var.resource_groups

  name     = each.key
  location = each.value.location
  tags     = each.value.tags
}
