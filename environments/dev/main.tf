locals {
  # Transformation logic to handle the nested map structure using FOR_EACH patterns
  rg_map = { for k, v in var.infra_config : k => v.resource_group }

  acr_map = {
    for pair in flatten([
      for rg_key, rg_val in var.infra_config : [
        for acr_key, acr_val in try(rg_val.registries, {}) : {
          key    = acr_key
          rg_key = rg_key
          config = acr_val
        }
      ]
      ]) : pair.key => {
      name                = pair.key
      resource_group_name = pair.rg_key
      location            = try(var.infra_config[pair.rg_key].resource_group.location, "East US")
      sku                 = try(pair.config.sku, "Standard")
      admin_enabled       = try(pair.config.admin_enabled, false)
      network_rules       = try(pair.config.network_rules, null)
      tags                = var.global_tags
    }
  }

  aks_map = {
    for pair in flatten([
      for rg_key, rg_val in var.infra_config : [
        for aks_key, aks_val in try(rg_val.clusters, {}) : {
          key    = aks_key
          rg_key = rg_key
          config = aks_val
        }
      ]
      ]) : pair.key => {
      name                = pair.key
      resource_group_name = pair.rg_key
      location            = try(var.infra_config[pair.rg_key].resource_group.location, "East US")
      dns_prefix          = pair.config.dns_prefix
      kubernetes_version  = try(pair.config.kubernetes_version, "1.29")
      sku_tier            = try(pair.config.sku_tier, "Free")
      default_node_pool = {
        name                 = pair.config.default_node_pool.name
        node_count           = try(pair.config.default_node_pool.node_count, 3)
        vm_size              = try(pair.config.default_node_pool.vm_size, "Standard_DS2_v2")
        os_disk_size_gb      = try(pair.config.default_node_pool.os_disk_size_gb, 30)
        auto_scaling_enabled = try(pair.config.default_node_pool.auto_scaling_enabled, false)
        min_count            = try(pair.config.default_node_pool.min_count, null)
        max_count            = try(pair.config.default_node_pool.max_count, null)
      }
      extra_node_pools = try(pair.config.extra_pools, {})
      tags             = var.global_tags
    }
  }
}

module "resource_groups" {
  source          = "../../modules/resource_group"
  resource_groups = local.rg_map
}

module "acrs" {
  source = "../../modules/acr"
  acrs   = local.acr_map

  depends_on = [module.resource_groups]
}

module "aks_clusters" {
  source       = "../../modules/aks"
  aks_clusters = local.aks_map

  depends_on = [module.resource_groups]
}

# Role Assignments
resource "azurerm_role_assignment" "aks_acr_pull" {
  for_each = {
    for k, v in local.aks_map : k => v
    if length(try(var.infra_config[v.resource_group_name].registries, {})) > 0
  }

  # Safely get the first registry ID for this Resource Group
  scope                = try(module.acrs.ids[keys(try(var.infra_config[each.value.resource_group_name].registries, {}))[0]], null)
  role_definition_name = "AcrPull"
  principal_id         = try(module.aks_clusters.kubelet_identities[each.key], null)

  depends_on = [module.acrs, module.aks_clusters]
}
