output "names" {
  value = { for k, v in azurerm_resource_group.this : k => v.name }
}

output "ids" {
  value = { for k, v in azurerm_resource_group.this : k => v.id }
}
