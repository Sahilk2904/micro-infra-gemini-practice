variable "acrs" {
  description = "Map of ACR configurations"
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku                 = optional(string, "Standard")
    admin_enabled       = optional(bool, false)
    tags                = optional(map(string), {})
    network_rules = optional(object({
      default_action = optional(string, "Allow")
      ip_rules       = optional(list(string), [])
    }))
  }))
}
