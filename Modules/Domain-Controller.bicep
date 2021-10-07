param location string = resourceGroup().location
param subNetID string
//param AutomationAccountName string = 'MIM-Automation'
param vmName string = 'MIM-DC01'

@description('Domain Name')
param domainName string = 'Contoso.com'


@description('Relative path for the DSC configuration module.')
param moduleFilePath string = 'DSC/CreateADPC.ps1.zip'

@description('The base URI where artifacts required by this template are located. When the template is deployed using the accompanying scripts, a private location in the subscription will be used and this value will be automatically generated.')
//param artifactsLocation string = deployment().properties.templateLink.uri
param artifactsLocation string = 'https://dev.azure.com/jobothw/_git/Templates'
@description('DSC configuration function to call')
param configurationFunction string = 'CreateADPDC.ps1\\CreateADPDC'

@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated.')
@secure()
param artifactsLocationSasToken string = ''

resource DC1NIC 'Microsoft.Network/networkInterfaces@2021-02-01' = {
  name: 'MIM-DC-01592'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subNetID
          }
        }
      }
    ]
  }
}

resource virtualMachines_MIM_DC_01_name_resource 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: vmName
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
        }
        diskSizeGB: 127
      }
      dataDisks: []
    }
    osProfile: {
      computerName: vmName
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
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: DC1NIC.id
          properties: {
            primary: true
            deleteOption: 'Delete'
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

resource vmName_vmExtensionName 'Microsoft.Compute/virtualMachines/extensions@2019-12-01' = {
  parent: virtualMachines_MIM_DC_01_name_resource
  name: 'CreateADForest'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      ModulesUrl: uri('${artifactsLocation}/DSC/CreateADPC.zip', '${moduleFilePath}${artifactsLocationSasToken}')
      ConfigurationFunction: configurationFunction
      Properties: {
        DomainNam: domainName
        AdminCreds: {
          UserName: 'xAdminstrator'
          Password: '1qazXSW@3edcVFR$'
        }
        MachineName: vmName
      }
    }
  }
}

