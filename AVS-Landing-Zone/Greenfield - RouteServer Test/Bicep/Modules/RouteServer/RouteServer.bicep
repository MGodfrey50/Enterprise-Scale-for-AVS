param Location string
param Prefix string
param VNetName string
param RouteServerSubnetPrefix string
param RouteServerSubnetExists bool

var RouteServerName = '${Prefix}-RS'

resource VNet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: VNetName
}

resource RouteServerSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' = if (!RouteServerSubnetExists) {
  name: 'RouteServerSubnet'
  parent: VNet
  properties: {
    addressPrefix: RouteServerSubnetPrefix
  }
}

resource ExistingRouteServerSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-08-01' existing = if (RouteServerSubnetExists) {
  name: '${VNet.name}/GatewaySubnet'
}

resource RouteServerPIP 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${RouteServerName}-PIP'
  location: Location
  properties: {
    publicIPAllocationMethod: 'Static'
  }
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

resource RouteServer 'Microsoft.Network/virtualHubs@2021-05-01' = {
  name: RouteServerName
  location: Location
  properties: {
    allowBranchToBranchTraffic: true
    sku: 'Standard'
  }
}

resource RouteServerIPConfigurationNewSubnet 'Microsoft.Network/virtualHubs/ipConfigurations@2021-05-01' = if (!RouteServerSubnetExists) {
  name: '${RouteServerName}-ipconfig'
  parent: RouteServer
  properties: {
    subnet: {
      id: RouteServerSubnet.id
    }
    publicIPAddress: {
      id: RouteServerPIP.id
    }
  }
}

resource RouteServerIPConfigurationExistingSubnet 'Microsoft.Network/virtualHubs/ipConfigurations@2021-05-01' = if (!RouteServerSubnetExists) {
  name: '${RouteServerName}-ipconfig'
  parent: RouteServer
  properties: {
    subnet: {
      id: ExistingRouteServerSubnet.id
    }
    publicIPAddress: {
      id: RouteServerPIP.id
    }
  }
}

output RouteServer string = RouteServer.name
output NewRouteServerSubnetId string = RouteServerSubnet.id
output ExistingRouteServerSubnetId string = ExistingRouteServerSubnet.id
