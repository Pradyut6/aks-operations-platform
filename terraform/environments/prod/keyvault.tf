module "keyvault" {

  source = "../../modules/keyvault"

  name = var.key_vault_name

  location = var.location

  resource_group_name = module.shared_rg.resource_group_name

  tenant_id = data.azurerm_client_config.current.tenant_id

  tags = local.common_tags

}