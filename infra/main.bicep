targetScope = 'subscription'

@minLength(1)
@maxLength(16)
@description('Prefix for all resources, i.e. {name}storage')
param name string

@minLength(1)
@description('Primary location for all resources')
param location string = deployment().location


resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'rg-${name}'
  location: location
}


module appservice './modules/AppService.bicep' = {
  name: '${rg.name}-appservice'
  scope: rg
  params: {
    location: rg.location
  }
}

module appconfig './modules/AppConfigurationService.bicep' = {
  name: '${rg.name}-appconfig'
  scope: rg
  params: {
    location: rg.location
  }
}

module keyvault './modules/KeyVault.bicep' = {
  name: '${rg.name}-keyvault'
  scope: rg
  params: {
    location: rg.location
  }
}


module configurServices './modules/ConfigureServices.bicep' = {
  name: '${rg.name}-configure-services'
  scope: rg
  params: {
    appServiceName: appservice.outputs.appServiceName
    configStoreName: appconfig.outputs.appConfigServiceName
    keyVaultName: keyvault.outputs.keyVaultName
  }
  dependsOn: [
    appservice
    appconfig
    keyvault
  ]
}
