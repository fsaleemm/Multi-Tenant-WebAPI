param ConfigAppName string = uniqueString(resourceGroup().id)
@description('Specifies the name of the app configuration store.')
param configStoreName string = toLower('AppConfig-${ConfigAppName}')

@description('Specifies the Azure location where the app configuration store should be created.')
param location string = resourceGroup().location

@description('Specifies the SKU of the app configuration store.')
param skuName string = 'standard'

resource configStore 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' = {
  name: configStoreName
  location: location
  sku: {
    name: skuName
  }
}

output appConfigServiceName string = configStore.name
