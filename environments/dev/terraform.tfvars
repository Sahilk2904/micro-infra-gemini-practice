infra_config = {
  "rg-dev-app-01" = {
    resource_group = {
      location = "East US"
      tags     = { Dept = "IT" }
    }
    registries = {
      "acrdevapp01" = {
        sku           = "Premium"
        admin_enabled = true
        network_rules = {
          default_action = "Deny"
          ip_rules       = ["1.2.3.4/32"]
        }
      }
    }
    clusters = {
      "aks-dev-01" = {
        dns_prefix         = "aksdev01"
        kubernetes_version = "1.30"
        default_node_pool = {
          name       = "system"
          node_count = 2
          vm_size    = "Standard_DS2_v2"
        }
        extra_pools = {
          "userpool" = {
            vm_size    = "Standard_DS3_v2"
            node_count = 1
          }
        }
      }
    }
  }

  "rg-dev-data-01" = {
    resource_group = {
      location = "West US"
    }
    # No registries or clusters here - testing conditional iteration
  }
}

global_tags = {
  Environment = "Dev"
  Owner       = "DevOps"
}
