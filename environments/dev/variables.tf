variable "infra_config" {
  description = "Nested map configuration for all infrastructure components"
  type = map(object({
    resource_group = object({
      location = string
      tags     = optional(map(string), {})
    })

    registries = optional(map(object({
      sku           = optional(string, "Standard")
      admin_enabled = optional(bool, false)
      network_rules = optional(object({
        default_action = optional(string, "Deny")
        ip_rules       = optional(list(string), [])
      }))
    })), {})

    clusters = optional(map(object({
      dns_prefix         = string
      kubernetes_version = optional(string, "1.33")
      sku_tier           = optional(string, "Free")
      default_node_pool = object({
        name                 = string
        node_count           = optional(number, 3)
        vm_size              = optional(string, "Standard_DC2as_v5")
        os_disk_size_gb      = optional(number, 30)
        auto_scaling_enabled = optional(bool, false)
        min_count            = optional(number, null)
        max_count            = optional(number, null)
      })
      extra_pools = optional(map(object({
        vm_size              = string
        node_count           = number
        auto_scaling_enabled = optional(bool, false)
        min_count            = optional(number, null)
        max_count            = optional(number, null)
      })), {})
    })), {})
  }))
}

variable "global_tags" {
  type = map(string)
  default = {
    Environment = "Dev"
    Project     = "Advanced-Modular"
  }
}
