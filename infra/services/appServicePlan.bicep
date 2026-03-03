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
  kind: 'app'
  properties: {
    reserved: false
  }
}

output planId string = appServicePlan.id
