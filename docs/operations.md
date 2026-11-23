# AKS operations and releases

## Bootstrap access

Before applying Terraform, create the Azure DevOps agent pool `AKS-Operations-Agents` and store the pool-registration PAT in the bootstrap Key Vault. The agent registers from the AKS VNet and uses the public IP for outbound connectivity. Direct SSH has no inbound rule unless `agent_ssh_source` is set.

From a VNet-connected workstation, authenticate using Azure CLI and get the Entra-enabled cluster credentials. Use `kubelogin` in Azure CLI mode. Create the workload namespace with an administrator identity.

```sh
cluster=$(terraform output -raw aks_cluster_name)
group=$(terraform output -raw aks_resource_group_name)
az aks get-credentials --resource-group "$group" --name "$cluster" --format exec
kubelogin convert-kubeconfig -l azurecli
kubectl create namespace aks-operations --dry-run=client -o yaml | kubectl apply -f -
```

Grant the AKS deployment service connection the **Azure Kubernetes Service Cluster User Role** on the cluster and **Azure Kubernetes Service RBAC Admin** on the `aks-operations` namespace scope. The namespace role is required to apply the dashboard Role and RoleBinding. Keep the registry publisher on a separate ACR-scoped `AcrPush` assignment. The cluster's kubelet identity receives `AcrPull` through Terraform. [Microsoft Entra authorization for AKS](https://learn.microsoft.com/en-us/azure/aks/entra-id-authorization)

## Verify a release

- Confirm the build completed its Trivy gate and published the manifest artifact with `image-digest.txt`. Review that digest when approving the deployment.
- Confirm rollout status and the configured image reference with `kubectl -n aks-operations rollout status deployment/aks-operations` and `kubectl -n aks-operations get deployment aks-operations -o jsonpath='{.spec.template.spec.containers[0].image}'`.
- Use `kubectl -n aks-operations port-forward svc/aks-operations 8080:80` and request `http://localhost:8080/health`.
- For the optional dashboard, apply workload overrides that set `DASHBOARD_ENABLED=true` and `automountServiceAccountToken: true` on the pod. Retain the namespaced RoleBinding and restrict network access to the dashboard.

## Diagnose and roll back

- If the agent is offline, check cloud-init, agent pool membership, and the VM identity's access to the bootstrap vault.
- If the deployment cannot reach AKS, verify private DNS and routing from the agent. For authorization failures, confirm the service connection identity and its cluster and namespace grants.
- If the image cannot be pulled, check the deployment digest against the release artifact and verify ACR access for the kubelet identity.
- Roll back by applying the last approved manifest artifact and verifying rollout. For immediate recovery, run `kubectl -n aks-operations rollout undo deployment/aks-operations` and reconcile the pipeline to the known-good digest.

## Clean up

Remove an optional Gateway and HTTPRoute before destroying the underlying infrastructure. With the same remote state and Azure credentials, review `terraform plan -destroy` and then run `terraform destroy`. The shared bootstrap vault and state account are managed separately.
