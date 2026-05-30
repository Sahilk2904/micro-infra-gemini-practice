variable "aks_clusters" {
  description = "Map of AKS configurations"
  type        = any # Using any to allow the module to receive the complex map without strict object typing issues
}
