param natGatewayName string = 'NATGateway'
param bastion_name string = 'MIMBastion'
param vnet_name string = 'mim-vnet'
param public_IPAddress_name string = 'mim-vnet-ip'
//param location string = 'eastus'
param location string = resourceGroup().location
param webSubnet_name string = 'WebSubnet'
param SQLSubnet_name string = 'SQLSubnet'
param appSubnet_name string = 'AppSubnet'
param dcSubnet_name string = 'DCSubnet'
@secure()
param adminPassword string = ''

resource bastionHostIP 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'bastionIPName'
  location: 'eastus'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource natGatewayIPname 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: 'natGatewayPublicIPName'
  location: 'eastus'
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    //ipAddress: '20.106.167.52'
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource natGatewayName_resource 'Microsoft.Network/natGateways@2020-11-01' = {
  name: natGatewayName
  location: 'eastus'
  sku: {
    name: 'Standard'
  }
  properties: {
    idleTimeoutInMinutes: 10
    publicIpAddresses: [
      {
        id: natGatewayIPname.id
      }
    ]
  }
}

resource public_IPAddress_name_resource 'Microsoft.Network/publicIPAddresses@2020-11-01' = {
  name: public_IPAddress_name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
    idleTimeoutInMinutes: 4
    ipTags: []
  }
}

resource vnet_name_resource 'Microsoft.Network/virtualNetworks@2020-11-01' = {
  name: vnet_name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: '10.0.0.0/27'
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: webSubnet_name
        properties: {
          addressPrefix: '10.0.1.0/27'
          natGateway: {
            id: natGatewayName_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: SQLSubnet_name
        properties: {
          addressPrefix: '10.0.2.0/27'
          natGateway: {
            id: natGatewayName_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: appSubnet_name
        properties: {
          addressPrefix: '10.0.3.0/27'
          natGateway: {
            id: natGatewayName_resource.id
          }
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
      {
        name: dcSubnet_name
        properties: {
          addressPrefix: '10.0.4.0/27'
          natGateway: {
            id: natGatewayName_resource.id
          }
          serviceEndpoints: []
          delegations: []
          privateEndpointNetworkPolicies: 'Enabled'
          privateLinkServiceNetworkPolicies: 'Enabled'
        }
      }
    ]
    virtualNetworkPeerings: []
    enableDdosProtection: false
  }
}

resource vnet_name_dcSubnet 'Microsoft.Network/VirtualNetworks/subnets@2019-11-01' = {
  parent: vnet_name_resource
  name: 'dcSubnet'
  properties: {
    addressPrefix: '10.0.4.0/27'
    natGateway: {
      id: natGatewayName_resource.id
    }
    serviceEndpoints: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource vnet_name_AzureBastionSubnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' = {
  parent: vnet_name_resource
  name: 'AzureBastionSubnet'
  properties: {
    addressPrefix: '10.0.0.0/27'
    delegations: []
    privateEndpointNetworkPolicies: 'Enabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

resource bastion_name_resource 'Microsoft.Network/bastionHosts@2020-11-01' = {
  name: bastion_name
  location: location
  properties: {
    dnsName: 'bst-f1e99eeb-bd3a-452e-95f2-c4b329153292.bastion.azure.com'
    ipConfigurations: [
      {
        name: 'IpConf'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: public_IPAddress_name_resource.id
          }
          subnet: {
            id: vnet_name_AzureBastionSubnet.id
          }
        }
      }
    ]
  }
}

resource nsg_name 'Microsoft.Network/networkSecurityGroups@2020-07-01' = {
  name: 'Bastion-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'AllowHttpsInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'Internet'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 100
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowGatewayManagerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'GatewayManager'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 110
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowLoadBalancerInBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: 'AzureLoadBalancer'
          destinationPortRange: '443'
          destinationAddressPrefix: '*'
          access: 'Allow'
          priority: 120
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 130
          direction: 'Inbound'
        }
      }
      {
        name: 'DenyAllInBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Inbound'
        }
      }
      {
        name: 'AllowSshRdpOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRanges: [
            '22'
            '3389'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 100
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowAzureCloudCommunicationOutBound'
        properties: {
          protocol: 'Tcp'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationPortRange: '443'
          destinationAddressPrefix: 'AzureCloud'
          access: 'Allow'
          priority: 110
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowBastionHostCommunicationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationPortRanges: [
            '8080'
            '5701'
          ]
          destinationAddressPrefix: 'VirtualNetwork'
          access: 'Allow'
          priority: 120
          direction: 'Outbound'
        }
      }
      {
        name: 'AllowGetSessionInformationOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: 'Internet'
          destinationPortRanges: [
            '80'
            '443'
          ]
          access: 'Allow'
          priority: 130
          direction: 'Outbound'
        }
      }
      {
        name: 'DenyAllOutBound'
        properties: {
          protocol: '*'
          sourcePortRange: '*'
          destinationPortRange: '*'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
          access: 'Deny'
          priority: 1000
          direction: 'Outbound'
        }
      }
    ]
  }
}

module dcModule 'Modules/Domain-Controller.bicep' = {
  name: 'dcDeploy'
  params:{
    location: location
    subNetID: vnet_name_dcSubnet.id
    adminPassword: adminPassword
  }
  dependsOn: [
    vnet_name_dcSubnet
  ]
}
output stringoutput string = vnet_name_dcSubnet.id
