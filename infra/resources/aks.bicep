param name string
param location string
param kubernetesVersion string

@description('Custom tags to apply to the resources')
param tags object = {}

resource aks 'Microsoft.ContainerService/managedClusters@2025-05-01' = {
  location: location
  name: name
  properties: {
    dnsPrefix: '${name}-dns'
    kubernetesVersion: kubernetesVersion
    enableRBAC: true

    workloadAutoScalerProfile: {
      keda: {
        enabled: false // Installed via Helm as a workaround as we need KEDA 2.10 for Prometheus workload identity authentication
      }
      verticalPodAutoscaler: {
        enabled: true
      }
    }
    
    ingressProfile: {
      webAppRouting: {
        enabled: true
      }
    }

    agentPoolProfiles: [
      {
        name: 'systempool'
        osDiskSizeGB: 0 // default size
        osDiskType: 'Ephemeral'
        enableAutoScaling: true
        count: 1
        minCount: 1
        maxCount: 3
        vmSize: 'Standard_DS4_v2'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'System'
        maxPods: 250
        nodeLabels: {
        }
        nodeTaints: []
        enableNodePublicIP: false
        tags: tags
      }
      {
        name: 'workerpool'
        osDiskSizeGB: 0 // default size
        osDiskType: 'Ephemeral'
        enableAutoScaling: true
        count: 1
        minCount: 1
        maxCount: 3
        vmSize: 'Standard_DS4_v2'
        osType: 'Linux'
        type: 'VirtualMachineScaleSets'
        mode: 'User'
        maxPods: 250
        nodeLabels: {
        }
        nodeTaints: []
        enableNodePublicIP: false
        tags: tags
      }
    ]

    apiServerAccessProfile: {
      enablePrivateCluster: false
    }

    azureMonitorProfile: {
      metrics: {
        enabled: true
        kubeStateMetrics: {
          metricLabelsAllowlist: ''
          metricAnnotationsAllowList: ''
        }
      }
    }

    networkProfile: {
      loadBalancerSku: 'standard'
      networkPlugin: 'azure'
      networkPluginMode: 'overlay'
      outboundType: 'loadBalancer'
    }
    
    oidcIssuerProfile: {
      enabled: true
    }
    autoUpgradeProfile: {
      upgradeChannel: 'patch'
    }
    addonProfiles: {
      azurepolicy: {
        enabled: true
      }
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true
      }
    }
  }
  tags: tags
  sku: {
    name: 'Base'
    tier: 'Standard'
  }
  identity: {
    type: 'SystemAssigned'
  }
}

@description('The AKS cluster identity')
output clusterIdentity object = {
  clientId: aks.properties.identityProfile.kubeletidentity.clientId
  objectId: aks.properties.identityProfile.kubeletidentity.objectId
  resourceId: aks.properties.identityProfile.kubeletidentity.resourceId
}

output name string = aks.name
output aksOidcIssuer string = aks.properties.oidcIssuerProfile.issuerURL
