param virtualMachines_MIM_DC01_name string = 'MIM-DC01'
param disks_MIM_DC01_disk1_8207eb8f6783441eb185329d690bdf0c_externalid string = '/subscriptions/cb012496-ce0b-4c24-9afe-bb7e27ca8f42/resourceGroups/MIM-rg/providers/Microsoft.Compute/disks/MIM-DC01_disk1_8207eb8f6783441eb185329d690bdf0c'
param networkInterfaces_mim_dc01833_externalid string = '/subscriptions/cb012496-ce0b-4c24-9afe-bb7e27ca8f42/resourceGroups/MIM-rg/providers/Microsoft.Network/networkInterfaces/mim-dc01833'

resource virtualMachines_MIM_DC01_name_resource 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: virtualMachines_MIM_DC01_name
  location: 'eastus'
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
        name: '${virtualMachines_MIM_DC01_name}_disk1_8207eb8f6783441eb185329d690bdf0c'
        createOption: 'FromImage'
        caching: 'ReadWrite'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          id: disks_MIM_DC01_disk1_8207eb8f6783441eb185329d690bdf0c_externalid
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: virtualMachines_MIM_DC01_name
      adminUsername: 'xadministrator'
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
      networkInterfaces: [
        {
          id: networkInterfaces_mim_dc01833_externalid
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
