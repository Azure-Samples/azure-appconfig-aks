#!/bin/bash

echo "Retrieving cluster credentials"
az aks get-credentials --resource-group ${AZURE_RESOURCE_GROUP} --name ${AZURE_AKS_CLUSTER_NAME}

appConfigProviderStatus=$(helm status azureappconfiguration.kubernetesprovider -n azappconfig-system 2>&1)
if [[ $appConfigProviderStatus == *"Error: release: not found"* ]]; then
    echo "Azure App configuration Kubernetes provider not installed, installing"
    helm install azureappconfiguration.kubernetesprovider oci://mcr.microsoft.com/azure-app-configuration/helmchart/kubernetes-provider --namespace azappconfig-system --create-namespace 
else
  echo "Azure App configuration Kubernetes provider installed, skipping"
fi

az appconfig kv import --source file --path "./app/config/sourceSettings.json" --name "${AZURE_APP_CONFIGURATION_NAME}" --label demo-app --separator __ --format json --yes