@description('Location')
param location string = resourceGroup().location

@description('App Service Plan Name')
param appServicePlanName string

@description('App Name')
param appName string

@description('SKU Name')
param skuName string = 'B1'

@description('Existing SQL Server name')
param sqlServerName string

@description('Existing database name')
param dbName string

@description('SQL admin username')
param adminUsername string

@secure()
param adminPassword string


// --------------------------------------------
// Reference Existing SQL Server
// --------------------------------------------
resource sqlServer 'Microsoft.Sql/servers@2023-05-01-preview' existing = {
  name: sqlServerName
}

// --------------------------------------------
// Seed Database
// --------------------------------------------
resource seedDb 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'seedDatabase'
  location: location
  kind: 'AzurePowerShell'
  dependsOn: [
    sqlServer
  ]
  properties: {
    azPowerShellVersion: '11.0'
    environmentVariables: [
      {
        name: 'SQL_SERVER'
        value: sqlServerName
      }
      {
        name: 'DB_NAME'
        value: dbName
      }
      {
        name: 'ADMIN_USER'
        value: adminUsername
      }
      {
        name: 'ADMIN_PASS'
        secureValue: adminPassword
      }
    ]    
    scriptContent: '''
$server = $env:SQL_SERVER
$db = $env:DB_NAME
$user = $env:ADMIN_USER
$pass = $env:ADMIN_PASS
Write-Output "Seeding Azure SQL Database..."

Install-Module -Name SqlServer -Force -Scope CurrentUser
Import-Module SqlServer

$connectionString = "Server=tcp:$server.database.windows.net,1433;Initial Catalog=$db;User ID=$user;Password=$pass;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;"

$query = @"
IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='Products' AND xtype='U')
BEGIN
    CREATE TABLE Products (
        Id INT PRIMARY KEY IDENTITY(1,1),
        Name NVARCHAR(100),
        Price DECIMAL(10,2)
    );
END;

IF NOT EXISTS (SELECT * FROM Products)
BEGIN
    INSERT INTO Products (Name, Price)
    VALUES ('Laptop', 1200), ('Mouse', 25);
END;
"@

Invoke-Sqlcmd -ConnectionString $connectionString -Query $query

Write-Output "Database seed complete."
'''
    timeout: 'PT10M'
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}

// --------------------------------------------
// App Service Plan Module
// --------------------------------------------
module appServicePlan './services/appServicePlan.bicep' = {
  name: 'appServicePlanModule'
  params: {
    location: location
    appServicePlanName: appServicePlanName
    skuName: skuName
  }
}


var dbConnectionString = 'Server=tcp:${sqlServerName}.database.windows.net,1433;Initial Catalog=${dbName};User ID=${adminUsername};Password=${adminPassword};Encrypt=true;Connection Timeout=30;'
// --------------------------------------------
// App Service Module
// --------------------------------------------
module appService './services/appService.bicep' = {
  name: 'appServiceModule'
  dependsOn: [
    seedDb
    appServicePlan
  ]
  params: {
    location: location
    appName: appName
    appServicePlanName: appServicePlanName
    dbConnectionString: dbConnectionString
  }
}
