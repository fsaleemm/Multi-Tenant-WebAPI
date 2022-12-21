param webAppName string = uniqueString(resourceGroup().id) // Generate unique String for web app name
param sku string = 'S1' // The SKU of App Service Plan
param location string = resourceGroup().location // Location for all resources
param repositoryUrl string = 'https://github.com/fsaleemm/Multi-Tenant-WebAPI.git'
param branch string = 'main'
var appServicePlanName = toLower('ASP-${webAppName}')
var webSiteName = toLower('wapi-${webAppName}')

resource appServicePlan 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: appServicePlanName
  location: location
  properties: {
    reserved: true
  }
  sku: {
    name: sku
  }
}

resource appService 'Microsoft.Web/sites@2020-06-01' = {
  name: webSiteName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      minTlsVersion: '1.2'
      linuxFxVersion: 'DOTNETCORE|6.0'
      appSettings: [
        
      ]
      connectionStrings: [
        {
          name: 'AppConfig'
          connectionString: '@Microsoft.KeyVault(VaultName=<Your-Key-Vault-Name>;SecretName=AppConfigConnectionString)'
          type: 'Custom'
        }
      ]
    }
  }
}

resource srcControls 'Microsoft.Web/sites/sourcecontrols@2021-01-01' = {
  name: '${appService.name}/web'
  properties: {
    repoUrl: repositoryUrl
    branch: branch
    isManualIntegration: true
  }
}

output appServiceName string = appService.name
