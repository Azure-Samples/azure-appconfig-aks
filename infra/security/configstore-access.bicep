param configStoreName string
param principalId string

resource configStore 'Microsoft.AppConfiguration/configurationStores@2023-03-01' existing = {
  name: configStoreName
}

@description('This is the built-in app configuration data reader role. See https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#app-configuration-data-reader')
resource configStoreDataReaderDefinition 'Microsoft.Authorization/roleDefinitions@2018-01-01-preview' existing = {
  name: '516239f1-63e1-4d78-a4de-a74fb236a071'
}

resource acsDataReaderRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(resourceGroup().id, principalId, configStoreDataReaderDefinition.id)
  scope: configStore
  properties: {
    roleDefinitionId: configStoreDataReaderDefinition.id
    principalId: principalId
    principalType: 'ServicePrincipal' 
  }
}


