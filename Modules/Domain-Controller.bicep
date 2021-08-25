param location string
param subscriptionID string
param osDiskID string = concat('/subscriptions/${subscriptionID}/resourceGroups/MIM-rg/providers/Microsoft.Compute/disks/MIM-DC-01_OsDisk')
param subNetID string

resource virtualMachines_MIM_DC_01_name_resource 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: 'MIM-DC01'
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ms'
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-datacenter-gensecond'
        version: 'latest'
      }
      osDisk: {
        osType: 'Windows'
        name: 'OsDisk'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          id: osDiskID
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: 'MIM-DC01'
      adminUsername: 'xAdministrator'
      adminPassword: '1qazXSW@3edcVFR$'
      windowsConfiguration: {
        provisionVMAgent: true
        enableAutomaticUpdates: true
        patchSettings: {
          patchMode: 'AutomaticByOS'
          assessmentMode: 'ImageDefault'
          enableHotpatching: false
        }
      }
      secrets: []
      allowExtensionOperations: true
      requireGuestProvisionSignal: true
    }
    networkProfile: {
      networkApiVersion: '2020-11-01'
      networkInterfaceConfigurations: [
        {
          name: 'MIM-DC-01592'
          properties: {
            deleteOption: 'Delete'
            ipConfigurations: [
              {
                name: 'MIM-DC01-pi'
                properties: {
                  primary: true
                  privateIPAddressVersion: 'IPv4'
                  subnet: {
                    id: subNetID
                  }
                }
              }
            ]
          }
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}
