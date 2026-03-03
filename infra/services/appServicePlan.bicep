@description('Location for resources')
param location string

@description('App Service Plan name')
param appServicePlanName string

@description('SKU name')
param skuName string

resource appServicePlan 'Microsoft.Web/serverfarms@2023-01-01' = {
  name: appServicePlanName
  location: location
  sku: {
    name: skuName
  }
  kind: 'linux'   // change from 'app' to 'linux'
  properties: {
    reserved: true   // must be true for Linux
  }
}

output planId string = appServicePlan.id
