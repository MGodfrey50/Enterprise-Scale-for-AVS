param Prefix string
param NetworkBlock string
param ManagementClusterSize int
param SKUName string
param Location string
param Internet string

resource PrivateCloud 'Microsoft.AVS/privateClouds@2021-12-01' = {
  name: '${Prefix}-SDDC'
  sku: {
    name: SKUName
  }
  identity: {
    type: 'SystemAssigned'
  }
  location: Location
  properties: {
    networkBlock: NetworkBlock
    internet: Internet
    managementCluster: {
      clusterSize: ManagementClusterSize
    }
  }
}

output PrivateCloudName string = PrivateCloud.name
output PrivateCloudResourceId string = PrivateCloud.id
