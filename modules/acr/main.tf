resource "azurerm_container_registry" "this" {
  for_each = try(var.acrs, {})

  name                = each.value.name
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = try(each.value.sku, "Standard")
  admin_enabled       = try(each.value.admin_enabled, false)
  tags                = try(each.value.tags, {})

  dynamic "network_rule_set" {
    for_each = each.value.network_rules != null ? [each.value.network_rules] : []
    content {
      default_action = try(network_rule_set.value.default_action, "Deny")
      dynamic "ip_rule" {
        for_each = try(network_rule_set.value.ip_rules, [])
        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }
    }
  }
}
