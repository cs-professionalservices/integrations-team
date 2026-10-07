resource "azurerm_resource_group" "rg" {
  name     = "logicapp-rg"
  location = "East US"
}

resource "azurerm_log_analytics_workspace" "law" {
  name                = "logicapp-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}


resource "azurerm_logic_app_workflow" "fail_no_diag" {
  name                = "bad-logic-app-no-diag"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}


resource "azurerm_logic_app_workflow" "fail_legacy_log_actionruns" {
  name                = "bad-logic-app-actionruns"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_monitor_diagnostic_setting" "fail_legacy_log_actionruns" {
  name               = "diag"
  target_resource_id = azurerm_logic_app_workflow.fail_legacy_log_actionruns.id

  log {
    category = "ActionRuns"
    enabled  = true
  }

  workspace_id = "/subscriptions/xxx/workspaces/test"
}


resource "azurerm_logic_app_workflow" "fail_legacy_log_no_dest" {
  name                = "bad-logic-app-legacy-no-dest"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_monitor_diagnostic_setting" "fail_legacy_log_no_dest" {
  name               = "diag"
  target_resource_id = azurerm_logic_app_workflow.fail_legacy_log_no_dest.id

  log {
    category = "WorkflowRuntime"
    enabled  = true
  }
}


resource "azurerm_logic_app_workflow" "fail_allmetrics" {
  name                = "bad-logic-app-allmetrics"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_monitor_diagnostic_setting" "fail_allmetrics" {
  name                       = "logicapp-diagnostics"
  target_resource_id         = azurerm_logic_app_workflow.fail_allmetrics.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.law.id

  enabled_log {
    category = "AllMetrics"
  }
}


resource "azurerm_logic_app_workflow" "fail_enabled_log_no_dest" {
  name                = "bad-logic-app-2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_monitor_diagnostic_setting" "fail_enabled_log_no_dest" {
  name               = "logicapp-diagnostics"
  target_resource_id = azurerm_logic_app_workflow.fail_enabled_log_no_dest.id

  enabled_log {
    category = "WorkflowRuntime"
  }
}
