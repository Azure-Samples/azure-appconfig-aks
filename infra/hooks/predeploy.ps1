Write-Host "Import the settings to Azure App Configuration"
az appconfig kv import --source file --path "./app/config/sourceSettings.json" --name $env:AZURE_APP_CONFIGURATION_NAME --label demo-app --separator __ --format json --yes

Write-Host "Retrieving cluster credentials"
az aks get-credentials --resource-group $env:AZURE_RESOURCE_GROUP --name $env:AZURE_AKS_CLUSTER_NAME

helm status azureappconfiguration.kubernetesprovider -n azappconfig-system

if ($LASTEXITCODE -eq 0) {
  Write-Host "Azure App configuration Kubernetes provider installed, skipping"
} else {
  Write-Host "Azure App configuration Kubernetes provider not installed, installing"
  helm install azureappconfiguration.kubernetesprovider oci://mcr.microsoft.com/azure-app-configuration/helmchart/kubernetes-provider --namespace azappconfig-system --create-namespace
}
