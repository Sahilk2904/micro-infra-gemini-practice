output "rg_names" {
  value = module.resource_groups.names
}

output "acr_logins" {
  value = module.acrs.login_servers
}

output "aks_ids" {
  value = module.aks_clusters.ids
}
