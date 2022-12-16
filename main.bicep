@sys.description('The Web App name.')
@minLength(3)
@maxLength(30)
param appBEPR string = 'portega-assignment-be-pr'
@sys.description('The Web App name.')
@minLength(3)
@maxLength(30)
param appFEPr string = 'portega-assignment-fe-pr'
@sys.description('The App Service Plan name.')
@minLength(3)
@maxLength(30)
param appServicePR string = 'portega-assignment-pr'
@sys.description('The Web App name.')
@minLength(3)
@maxLength(30)
param appBE_DV string = 'portega-assignment-be-dv'
@minLength(3)
@maxLength(30)
param appFE_DV string = 'portega-assignment-fe-dv'
@sys.description('The App Service Plan name.')
@minLength(3)
@maxLength(30)
param appServiceDV string = 'portega-assignment-dv'
@sys.description('The Storage Account name.')
@minLength(3)
@maxLength(30)
param storageAccountName string = 'portegastorage'
@allowed([
  'nonprod'
  'prod'
  ])
param environmentType string = 'nonprod'
param location string = resourceGroup().location


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

module appBEPr 'modules/appStuff.bicep' = if (environmentType == 'prod') {
  name: 'appBEPr'
  params: { 
    location: location
    appServiceAppName: appBEPR
    appServicePlanName: appServicePR
    
  }
}

module appFEPR 'modules/appStuff.bicep' = if (environmentType == 'prod') {
  name: 'appFEPR'
  params: { 
    location: location
    appServiceAppName: appFEPr
    appServicePlanName: appServicePR
  }
}

module appBEDV 'modules/appStuff.bicep' = if (environmentType == 'nonprod') {
  name: 'appBEDV'
  params: { 
    location: location
    appServiceAppName: appBE_DV
    appServicePlanName: appServiceDV
  }
}

module appfedv 'modules/appStuff.bicep' = if (environmentType == 'nonprod') {
  name: 'appfedv'
  params: { 
    location: location
    appServiceAppName: appFE_DV
    appServicePlanName: appServiceDV
  }
}

  output appServiceAppHostName1 string = (environmentType == 'prod') ? appBEPr.outputs.appServiceAppHostName : appBEDV.outputs.appServiceAppHostName
  output appServiceAppHostName2 string = (environmentType == 'prod') ? appFEPR.outputs.appServiceAppHostName : appfedv.outputs.appServiceAppHostName
    