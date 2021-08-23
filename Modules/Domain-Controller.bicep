param location string
param subnetName string

resource dc_name_resource 'Microsoft.Compute/virtualMachines@2021-04-01' = {
  location: location
  name: 'MIM-DC01'

  diagnosticsProfile: {
    bootDiagnostics: {
      enabled: true
    }
  }
}
