variable "resource_groups" {
  description = "Map of resource group configurations"
  type = map(object({
    location = string
    tags     = optional(map(string), {})
  }))
}
