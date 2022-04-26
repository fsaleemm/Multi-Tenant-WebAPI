var UniqueName = uniqueString(resourceGroup().id)
var appServiceName = toLower('wapi-${UniqueName}')
var configStoreName = toLower('AppConfig-${UniqueName}')
var keyVaultName = toLower('kv-${UniqueName}')

resource appServiceInstance 'Microsoft.Web/sites@2020-06-01' existing = {
  name: appServiceName
}

resource configStoreInstance 'Microsoft.AppConfiguration/configurationStores@2021-10-01-preview' existing = {
  name: configStoreName
}

resource keyVaultInstance 'Microsoft.KeyVault/vaults@2021-11-01-preview' existing = {
  name: keyVaultName
}

// App Service Ids
var appServiceIdentity = appServiceInstance.identity.principalId


// App Configuration Service Connection String
var connString = configStoreInstance.listKeys().value[0].connectionString


// Configure Key Vault AppConfiguration secret
resource AppConfigConnection 'Microsoft.KeyVault/vaults/secrets@2021-11-01-preview' = {
  parent: keyVaultInstance
  name: 'AppConfigConnectionString'
  properties: {
    value: connString
  }
}

// Add KV Access Policy
resource AppServiceAccessPolicy 'Microsoft.KeyVault/vaults/accessPolicies@2021-11-01-preview' = {
  name: 'add'
  parent: keyVaultInstance
  properties: {
    accessPolicies: [
      {
        objectId: appServiceIdentity
        permissions: {
          secrets: [
            'get'
          ]
        }
        tenantId: appServiceInstance.identity.tenantId
      }
    ]
  }
}

// Create App Config Service Keys

  // Sentinel Key
  resource AppServiceAPISettingsSentinel 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
    parent: configStoreInstance
    name: 'AppServiceAPI:Settings:Sentinel'
    properties: {
      value: '0'
      contentType: 'application/json'
    }
  }

  // Alpha
resource AlphaSettingsCustomerName 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  parent: configStoreInstance
  name: 'Alpha:Settings:CustomerName'
  properties: {
    value: 'Customer Alpha'
    contentType: 'application/json'
  }
}

resource AlphaSettingsCustomerId 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  parent: configStoreInstance
  name: 'Alpha:Settings:CustomerId'
  properties: {
    value: '101'
    contentType: 'application/json'
  }
}

var keyVaultSecretURLAlpha =  '${keyVaultInstance.properties.vaultUri}secrets/AlphaConnectionStringsDBConnection'
var keyVaultRefAlpha = {
  uri: keyVaultSecretURLAlpha
}

resource AlphaConnectionStringsDBConnection 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  parent: configStoreInstance
  name: 'Alpha:ConnectionStrings:DBConnection'
  properties: {
    value: string(keyVaultRefAlpha)
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}


  // Bravo
resource BravoSettingsCustomerName 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  parent: configStoreInstance
  name: 'Bravo:Settings:CustomerName'
  properties: {
    value: 'Customer Bravo'
    contentType: 'application/json'
  }
}

resource BravoSettingsCustomerId 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  parent: configStoreInstance
  name: 'Bravo:Settings:CustomerId'
  properties: {
    value: '102'
    contentType: 'application/json'
  }
}

var keyVaultSecretURLBravo = '${keyVaultInstance.properties.vaultUri}secrets/BravoConnectionStringsDBConnection'
var keyVaultRefBravo = {
  uri: keyVaultSecretURLBravo
}

resource BravoConnectionStringsDBConnection 'Microsoft.AppConfiguration/configurationStores/keyValues@2021-10-01-preview' = {
  parent: configStoreInstance
  name: 'Bravo:ConnectionStrings:DBConnection'
  properties: {
    value: string(keyVaultRefBravo)
    contentType: 'application/vnd.microsoft.appconfig.keyvaultref+json;charset=utf-8'
  }
}


// App Service AppConfig KV Refernece

resource connectionString 'Microsoft.Web/sites/config@2020-06-01' = {
  parent: appServiceInstance
  name: 'connectionstrings'
  properties: {
    'AppConfig' : {
      value: '@Microsoft.KeyVault(VaultName=${keyVaultName};SecretName=AppConfigConnectionString)'
      type: 'Custom'
    }
  }
}
