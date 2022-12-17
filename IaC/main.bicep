@sys.description('The FE Web App name.')
@minLength(3)
@maxLength(30)
param appServiceAppNameFe string = 'portega--fe-app-bicep'
@sys.description('The BE Web App name.')
@minLength(3)
@maxLength(30)
param appServiceAppNameBe string = 'portega--be-app-bicep'
@sys.description('The App Service Plan name.')
@minLength(3)
@maxLength(24)
param appServicePlanName string = 'portega--app-bicep'
@sys.description('The Storage Account name.')
@minLength(3)
@maxLength(24)
param storageAccountName string = 'portega-storage'
@sys.description('The environment type.')
@allowed([
  'nonprod'
  'prod'
  ])
param environmentType string = 'nonprod'
param location string = resourceGroup().location
@secure()
param dbhost string
@secure()
param dbuser string
@secure()
param dbpass string
@secure()
param dbname string

var storageAccountSkuName = (environmentType == 'prod') ? 'Standard_GRS' : 'Standard_LRS'  
var appServicePlanSkuName = (environmentType == 'prod') ? 'B1' : 'F1'

@sys.description('The PostgreSQL server name.')
@minLength(3)
@maxLength(30)
param postgreServerName string = 'jseijas-dbsrv'

@sys.description('The PostgreSQL database name.')
@minLength(3)
@maxLength(30)
param dbnamee string = 'portega--db'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-05-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
resource postgreServer 'Microsoft.DBforPostgreSQL/servers@2017-12-01' existing = {
  name: postgreServerName
}
resource serverDatabase 'Microsoft.DBforPostgreSQL/servers/databases@2017-12-01' = {
  name: dbnamee
  parent: postgreServer
}
resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  kind: 'linux'
  sku: {
    name: appServicePlanSkuName
  }
  
}
resource appServiceAppFe 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppNameFe
  location: location
  properties: {
  serverFarmId: appServicePlan.id
  httpsOnly: true
  }
}
resource appServiceAppBe 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppNameBe
  location: location
  properties: {
  serverFarmId: appServicePlan.id
  httpsOnly: true
  siteConfig: {

    appSettings: [
      {
        name: 'DBHOST'
        value: dbhost
      }
      {
        name: 'DBUSER'
        value: dbuser
      }
      {
        name: 'DBPASS'
        value: dbpass
      }
      {
        name: 'DBNAME'
        value: dbname
      }
    ]
  }
  
}
}
