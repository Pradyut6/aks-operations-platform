module "acr" {

  source = "../../modules/acr"

  name = var.registry_name

  location = var.location

  resource_group_name = module.shared_rg.resource_group_name

  sku = "Basic"

  tags = local.common_tags

}