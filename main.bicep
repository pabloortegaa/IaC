@sys.description('The Web App name.')
@minLength(3)
@maxLength(30)
param appServiceAppName1 string = 'msanroman-app-prod-be'
@sys.description('The Web App name.')
@minLength(3)
@maxLength(30)
param appServiceAppName3 string = 'msanroman-app-prod-fe'
@sys.description('The App Service Plan name.')
@minLength(3)
@maxLength(30)
param appServicePlanName1 string = 'msanroman-app-prod'
@sys.description('The Web App name.')
@minLength(3)
@maxLength(30)
param appServiceAppName2 string = 'msanroman-app-dev-be'
@minLength(3)
@maxLength(30)
param appServiceAppName4 string = 'msanroman-app-dev-fe'
@sys.description('The App Service Plan name.')
@minLength(3)
@maxLength(30)
param appServicePlanName2 string = 'msanroman-app-dev'
@sys.description('The Storage Account name.')
@minLength(3)
@maxLength(30)
param storageAccountName string = 'msanromanstorage'
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

module appService1 'modules/appStuff.bicep' = if (environmentType == 'prod') {
  name: 'appService1'
  params: { 
    location: location
    appServiceAppName: appServiceAppName1
    appServicePlanName: appServicePlanName1
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

module appService3 'modules/appStuff.bicep' = if (environmentType == 'prod') {
  name: 'appService3'
  params: { 
    location: location
    appServiceAppName: appServiceAppName3
    appServicePlanName: appServicePlanName1
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

module appService2 'modules/appStuff.bicep' = if (environmentType == 'nonprod') {
  name: 'appService2'
  params: { 
    location: location
    appServiceAppName: appServiceAppName2
    appServicePlanName: appServicePlanName2
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

module appService4 'modules/appStuff.bicep' = if (environmentType == 'nonprod') {
  name: 'appService4'
  params: { 
    location: location
    appServiceAppName: appServiceAppName4
    appServicePlanName: appServicePlanName2
    dbhost: dbhost
    dbuser: dbuser
    dbpass: dbpass
    dbname: dbname
  }
}

  output appServiceAppHostName1 string = (environmentType == 'prod') ? appService1.outputs.appServiceAppHostName : appService2.outputs.appServiceAppHostName
  output appServiceAppHostName2 string = (environmentType == 'prod') ? appService3.outputs.appServiceAppHostName : appService4.outputs.appServiceAppHostName
