provider "azurerm" {
  features {}
}

resource "azurerm_log_analytics_workspace" "log_analytics_fail" {
  name                = "loganalytics-fail"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 130
  daily_quota_gb      = -1


  tags = {
    Compliance = "NON_COMPLIANT"
    Reason     = "No ingestion cap configured"
  }
}

resource "azurerm_log_analytics_workspace" "log_analytics_pass" {
  name                = "loganalytics-pass"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  daily_quota_gb      = 50

  tags = {
    Compliance = "COMPLIANT"
    Reason     = "Ingestion cap configured within threshold"
  }
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "East US"
}

resource "azurerm_storage_account" "example" {
  name                     = "examplestorageacct"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_log_analytics_linked_storage_account" "linked_pass" {
  resource_group_name    = azurerm_resource_group.example.name
  workspace_resource_id  = azurerm_log_analytics_workspace.log_analytics_pass.id
  data_source_type       = "CustomLogs"
  storage_account_ids    = [azurerm_storage_account.example.id]
}

resource "azurerm_log_analytics_linked_storage_account" "linked_fail" {
  resource_group_name    = azurerm_resource_group.example.name
  workspace_resource_id  = azurerm_log_analytics_workspace.log_analytics_fail.id
  data_source_type       = "CustomLogs"
  # storage_account_ids missing -> FAIL
}