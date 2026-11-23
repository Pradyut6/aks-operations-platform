variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "location" {
  description = "Azure Region"
  type        = string
}

variable "environment" {
  description = "Environment Name"
  type        = string
}

variable "ado_acr_service_principal_object_id" {
  description = "Object ID of the service principal used by the Azure DevOps ACR service connection"
  type        = string
}

variable "aks_admin_group_object_ids" {
  description = "Microsoft Entra group object IDs for AKS bootstrap administrators."
  type        = list(string)
}

variable "aks_private_cluster_enabled" {
  description = "Restrict the Kubernetes API endpoint to the private network."
  type        = bool
  default     = true
}

variable "registry_name" {
  description = "Globally unique Azure Container Registry name."
  type        = string
}

variable "key_vault_name" {
  description = "Globally unique workload Key Vault name."
  type        = string
}

variable "azure_devops_org_url" {
  description = "Azure DevOps organization URL."
  type        = string

  validation {
    condition     = can(regex("^https://dev[.]azure[.]com/[a-zA-Z0-9-]+/?$", var.azure_devops_org_url))
    error_message = "Use https://dev.azure.com/your-organization."
  }
}

variable "agent_ssh_public_key" {
  description = "Public key for the self-hosted agent VM."
  type        = string
}

variable "agent_ssh_source" {
  description = "Optional IPv4 CIDR for direct SSH. Null leaves SSH closed."
  type        = string
  default     = null

  validation {
    condition     = var.agent_ssh_source == null || try(cidrnetmask(var.agent_ssh_source) != "0.0.0.0", false)
    error_message = "Use an approved IPv4 CIDR with a nonzero prefix length."
  }
}

variable "agent_vm_size" {
  description = "VM size for Docker builds and vulnerability scanning."
  type        = string
  default     = "Standard_B2s"
}

variable "aks_system_vm_size" {
  description = "Non-burstable system node size with at least four vCPUs and 4 GB RAM."
  type        = string
  default     = "Standard_D4s_v5"

  validation {
    condition     = !startswith(lower(var.aks_system_vm_size), "standard_b")
    error_message = "AKS system pools do not support B-series VMs."
  }
}
