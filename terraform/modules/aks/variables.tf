variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "dns_prefix" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "identity_id" {
  type = string
}


variable "system_subnet_id" {
  type = string
}

variable "user_subnet_id" {
  type = string
}

variable "log_analytics_workspace_id" {
  type = string
}

variable "system_node_count" {
  type    = number
  default = 2
}

variable "system_vm_size" {
  type    = string
  default = "Standard_D4s_v5"
}

variable "tags" {
  type = map(string)
}

variable "system_node_min_count" {
  default = 2
}

variable "system_node_max_count" {
  default = 5
}

variable "tenant_id" {
  description = "Microsoft Entra tenant for AKS authentication."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs for AKS administrators."
  type        = list(string)

  validation {
    condition     = length(var.admin_group_object_ids) > 0
    error_message = "Supply at least one Entra administrator group object ID."
  }
}

variable "private_cluster_enabled" {
  description = "Use a private Kubernetes API endpoint."
  type        = bool
  default     = true
}
