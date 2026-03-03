param location string
param appName string
param appServicePlanName string
param dbConnectionString string

resource app 'Microsoft.Web/sites@2022-03-01' = {
  name: appName
  location: location
  kind: 'app,linux'
  properties: {
    serverFarmId: appServicePlanName
    siteConfig: {
      linuxFxVersion: 'NODE|22-lts'  // Node runtime for Linux
      appSettings: [
        {
          name: 'DB_CONNECTION_STRING'
          value: dbConnectionString
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }    
  }
}
