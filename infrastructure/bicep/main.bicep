targetScope = 'subscription'

@description('Name of the resource group for the data platform.')
param resourceGroupName string

@description('Azure region in which resources will be deployed.')
param location string = 'uksouth'

@description('Environment name.')
@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

@description('Globally unique storage account name.')
param storageAccountName string

@description('Globally unique Key Vault name.')
param keyVaultName string

@description('Log Analytics workspace name.')
param logAnalyticsWorkspaceName string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

module platformResources 'modules/platform-resources.bicep' = {
  name: 'platform-resources-${environment}'
  scope: resourceGroup
  params: {
    location: location
    storageAccountName: storageAccountName
    keyVaultName: keyVaultName
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
  }
}
