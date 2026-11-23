module "azure_devops_agent" {

  source = "../../modules/linux-vm"

  vm_name = "prod-ado-agent"

  location = var.location

  resource_group_name = module.shared_rg.resource_group_name

  subnet_id = module.agent_subnet.id

  agent_version = "4.260.0"
  agent_package = "vsts-agent-linux-x64-4.260.0.tar.gz"

  vm_size = var.agent_vm_size

  admin_username = "azureuser"

  allowed_ssh_ip       = var.agent_ssh_source
  public_key           = var.agent_ssh_public_key
  ado_org_url          = var.azure_devops_org_url
  bootstrap_vault_name = data.azurerm_key_vault.bootstrap.name

  identity_ids = [
    module.azure_devops_agent_identity.id
  ]

  depends_on = [
    module.agent_bootstrap_keyvault_role
  ]
}