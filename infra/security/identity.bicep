param name string
param federatedIdentityName string
param location string
param aksOidcIssuer string
param serviceAccountNamespace string = 'azure-appconfig-aks'
param serviceAccountName string = 'demo-service-account'

@description('Custom tags to apply to the resources')
param tags object = {}

resource appcsManagedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags
}

resource FederatedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities/federatedIdentityCredentials@2023-01-31' = {
  name: federatedIdentityName
  parent: appcsManagedIdentity
  properties: {
    audiences: [
      'api://AzureADTokenExchange'
    ]
    issuer: aksOidcIssuer
    subject: 'system:serviceaccount:${serviceAccountNamespace}:${serviceAccountName}'
  }
}

output managedIdentityPrincipalId string = appcsManagedIdentity.properties.principalId
output managedIdentityClientId string = appcsManagedIdentity.properties.clientId
