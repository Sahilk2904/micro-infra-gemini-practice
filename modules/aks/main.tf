terraform {
  required_version = ">= 1.8.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0.0"
    }
  }
}

resource "azurerm_kubernetes_cluster" "this" {
  for_each = try(var.aks_clusters, {})

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  dns_prefix          = each.value.dns_prefix
  kubernetes_version  = try(each.value.kubernetes_version, "1.33")
  sku_tier            = try(each.value.sku_tier, "Free")
  tags                = try(each.value.tags, {})

  default_node_pool {
    name                 = each.value.default_node_pool.name
    node_count           = try(each.value.default_node_pool.node_count, 3)
    vm_size              = try(each.value.default_node_pool.vm_size, "Standard_DC2as_v5")
    os_disk_size_gb      = try(each.value.default_node_pool.os_disk_size_gb, 30)
    auto_scaling_enabled = try(each.value.default_node_pool.auto_scaling_enabled, false)
    min_count            = try(each.value.default_node_pool.auto_scaling_enabled, false) ? each.value.default_node_pool.min_count : null
    max_count            = try(each.value.default_node_pool.auto_scaling_enabled, false) ? each.value.default_node_pool.max_count : null
  }

  identity {
    type = "SystemAssigned"
  }
}

locals {
  extra_node_pools_flat = flatten([
    for aks_key, aks_val in try(var.aks_clusters, {}) : [
      for pool_key, pool_val in try(aks_val.extra_node_pools, {}) : {
        aks_key              = aks_key
        pool_key             = pool_key
        vm_size              = pool_val.vm_size
        node_count           = pool_val.node_count
        auto_scaling_enabled = try(pool_val.auto_scaling_enabled, false)
        min_count            = try(pool_val.min_count, null)
        max_count            = try(pool_val.max_count, null)
      }
    ]
  ])
}

resource "azurerm_kubernetes_cluster_node_pool" "extra" {
  for_each = { for x in local.extra_node_pools_flat : "${x.aks_key}.${x.pool_key}" => x }

  name                  = each.value.pool_key
  kubernetes_cluster_id = try(azurerm_kubernetes_cluster.this[each.value.aks_key].id, null)
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  auto_scaling_enabled  = each.value.auto_scaling_enabled
  min_count             = each.value.auto_scaling_enabled ? each.value.min_count : null
  max_count             = each.value.auto_scaling_enabled ? each.value.max_count : null
}
