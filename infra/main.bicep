targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('The resource name of the AKS cluster')
param clusterName string = ''

@description('The resource name of the Container Registry (ACR)')
param containerRegistryName string = ''

@description('The resource name of the Azure App Configuraiton store')
param configStoreName string = ''

@description('The resource name of the Managed Identity')
param identityName string = ''

@description('The resource name of the Federated Credential')
param federatedIdentityName string = ''

param kubernetesVersion string = '1.28.5'

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

var abbrs = loadJsonContent('./abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

// The AKS cluster to host applications
module aks './resources/aks.bicep' = {
  name: 'aks'
  scope: rg
  params: {
    location: location
    name: !empty(clusterName) ? clusterName : '${abbrs.containerServiceManagedClusters}${resourceToken}'
    tags: tags
    kubernetesVersion: kubernetesVersion
  }
}

module identity './security/identity.bicep' = {
  name: 'identity'
  scope: rg
  params: {
    location: location
    name: !empty(identityName) ? identityName : '${abbrs.managedIdentityUserAssignedIdentities}${resourceToken}'
    federatedIdentityName: !empty(federatedIdentityName) ? federatedIdentityName : '${abbrs.federatedIdentityCredentials}${resourceToken}'
    aksOidcIssuer: aks.outputs.aksOidcIssuer
    tags: tags
  }
}

// The ACR to host container images
module acr './resources/acr.bicep' = {
  name: 'acr'
  scope: rg
  params: {
    location: location
    name: !empty(containerRegistryName) ? containerRegistryName : '${abbrs.containerRegistryRegistries}${resourceToken}'
    tags: tags
    principalId: aks.outputs.clusterIdentity.objectId
  }
}

module configStore './resources/configStore.bicep' = {
  name: 'configStore'
  scope: rg
  params: {
    location: location
    name: !empty(configStoreName) ? configStoreName : '${abbrs.appConfigurationStores}${resourceToken}'
    tags: tags
    principalId: identity.outputs.managedIdentityPrincipalId
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
output AZURE_RESOURCE_GROUP string = rg.name
output AZURE_AKS_CLUSTER_NAME string = aks.outputs.name
output AZURE_AKS_IDENTITY_CLIENT_ID string = aks.outputs.clusterIdentity.clientId
output AZURE_APP_CONFIGURATION_ENDPOINT string = configStore.outputs.endpoint
output AZURE_APP_CONFIGURATION_NAME string = !empty(configStoreName) ? configStoreName : '${abbrs.appConfigurationStores}${resourceToken}'
output AZURE_APP_CONFIGURATION_IDENTITY_CLIENT_ID string = identity.outputs.managedIdentityClientId
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = acr.outputs.loginServer
output AZURE_CONTAINER_REGISTRY_NAME string = acr.outputs.name
