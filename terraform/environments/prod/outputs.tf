output "agent_vm_public_ip" {
  value = module.azure_devops_agent.public_ip
}

output "aks_cluster_name" {
  value = module.aks.name
}

output "aks_resource_group_name" {
  value = module.aks_rg.resource_group_name
}

output "registry_login_server" {
  value = module.acr.login_server
}
