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
      appSettings: [
        {
          name: 'DB_CONNECTION_STRING'
          value: dbConnectionString
        }
        { 
          name: 'WEBSITE_NODE_DEFAULT_VERSION' 
          value: '18.16' 
        }
        {
          name: 'WEBSITE_RUN_FROM_PACKAGE'
          value: '1'
        }
      ]
    }    
  }
}
