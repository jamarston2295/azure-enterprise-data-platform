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

// -----------------------------------------------------------------------------
// Resource Group
// -----------------------------------------------------------------------------

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

// -----------------------------------------------------------------------------
// Storage Account - ADLS Gen2
// -----------------------------------------------------------------------------

resource storageAccount 'Microsoft.Storage/storageAccounts@2025-01-01' = {
  name: storageAccountName
  location: location
  kind: 'StorageV2'
  sku: {
    name: 'Standard_LRS'
  }
  properties: {
    isHnsEnabled: true
    minimumTlsVersion: 'TLS1_2'
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
  }
  scope: resourceGroup
}

// -----------------------------------------------------------------------------
// Key Vault
// -----------------------------------------------------------------------------

resource keyVault 'Microsoft.KeyVault/vaults@2024-12-01' = {
  name: keyVaultName
  location: location
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    publicNetworkAccess: 'Enabled'
  }
  scope: resourceGroup
}

// -----------------------------------------------------------------------------
// Log Analytics
// -----------------------------------------------------------------------------

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
  scope: resourceGroup
}
