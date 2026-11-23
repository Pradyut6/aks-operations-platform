locals {

  prefix = "${var.environment}-aks"

  common_tags = {

    Environment = var.environment

    Project = "AKS-Operations"

    Owner = "Platform"

    ManagedBy = "Terraform"

  }

}

module "network_rg" {

  source = "../../modules/resource-group"

  name = "${var.environment}-network-rg"

  location = var.location

  tags = local.common_tags

}

module "aks_rg" {

  source = "../../modules/resource-group"

  name = "${var.environment}-aks-rg"

  location = var.location

  tags = local.common_tags

}

module "shared_rg" {

  source = "../../modules/resource-group"

  name = "${var.environment}-shared-rg"

  location = var.location

  tags = local.common_tags

}

module "monitoring_rg" {

  source = "../../modules/resource-group"

  name = "${var.environment}-monitoring-rg"

  location = var.location

  tags = local.common_tags

}
