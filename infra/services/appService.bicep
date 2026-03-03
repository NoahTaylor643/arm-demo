param location string
param appName string
param appServicePlanName string
param dbConnectionString string

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlanName
    siteConfig: {
      linuxFxVersion: 'NODE|18-lts'
      appSettings: [
        {
          name: 'DB_CONNECTION_STRING'
          value: dbConnectionString
        }
      ]
    }    
  }
}
