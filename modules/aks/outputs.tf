output "ids" {
  value = { for k, v in azurerm_kubernetes_cluster.this : k => v.id }
}

output "kubelet_identities" {
  value = { for k, v in azurerm_kubernetes_cluster.this : k => v.kubelet_identity[0].object_id }
}
