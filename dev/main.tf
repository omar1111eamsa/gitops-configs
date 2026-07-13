data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.kubernetes_cluster_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.kubernetes_cluster_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name                 = "default"
    vm_size              = var.vm_size
    os_disk_size_gb      = 30
    auto_scaling_enabled = true
    min_count            = var.node_min_count
    max_count            = var.node_max_count
  }

  identity {
    type = "SystemAssigned"
  }

  local_account_disabled = false

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool[0].orchestrator_version
    ]
  }
}
