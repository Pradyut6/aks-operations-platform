resource "azurerm_kubernetes_cluster" "this" {

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  dns_prefix = var.dns_prefix
  tags       = var.tags

  kubernetes_version = var.kubernetes_version

  sku_tier = "Standard"

  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }


  azure_policy_enabled = true

  local_account_disabled = true

  private_cluster_enabled             = var.private_cluster_enabled
  private_cluster_public_fqdn_enabled = false

  role_based_access_control_enabled = true

  azure_active_directory_role_based_access_control {
    tenant_id              = var.tenant_id
    admin_group_object_ids = var.admin_group_object_ids
    azure_rbac_enabled     = true
  }

  automatic_upgrade_channel = "patch"

  node_os_upgrade_channel = "NodeImage"


  default_node_pool {

    name                         = "system"
    vm_size                      = var.system_vm_size
    node_count                   = var.system_node_count
    zones                        = ["1", "2"]
    os_disk_size_gb              = 100
    type                         = "VirtualMachineScaleSets"
    only_critical_addons_enabled = true
    temporary_name_for_rotation  = "systemtmp"
    vnet_subnet_id               = var.system_subnet_id

    upgrade_settings {
      max_surge = "10%"
    }

  }

  identity {

    type = "UserAssigned"

    identity_ids = [
      var.identity_id
    ]

  }

  network_profile {

    network_plugin = "azure"

    network_plugin_mode = "overlay"

    network_policy = "azure"

    load_balancer_sku = "standard"

  }

  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace_id
  }
}