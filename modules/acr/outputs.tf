output "ids" {
  value = { for k, v in azurerm_container_registry.this : k => v.id }
}

output "login_servers" {
  value = { for k, v in azurerm_container_registry.this : k => v.login_server }
}
