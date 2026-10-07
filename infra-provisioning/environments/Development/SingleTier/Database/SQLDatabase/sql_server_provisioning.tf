
resource "azurerm_mssql_server" "fail_no_entra_admin" {
  name                         = "mssql-fail-no-entra"
  resource_group_name          = "rg-example"
  location                     = "East US"
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"
}

resource "azurerm_mssql_server" "fail_no_login_username" {
  name                         = "mssql-fail-no-login"
  resource_group_name          = "rg-example"
  location                     = "East US"
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"

  azuread_administrator {
    object_id = "00000000-0000-0000-0000-000000000002"
  }
}

resource "azurerm_mssql_server" "fail_no_object_id" {
  name                         = "mssql-fail-no-object-id"
  resource_group_name          = "rg-example"
  location                     = "East US"
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "P@ssw0rd1234!"

  azuread_administrator {
    login_username = "entra-admin-user"
  }
}

resource "azurerm_resource_group" "fail_no_va" {
  name     = "rg-no-va"
  location = "East US"
}

resource "azurerm_mssql_server" "fail_no_va" {
  name                         = "sqlserver-no-va"
  resource_group_name          = azurerm_resource_group.fail_no_va.name
  location                     = azurerm_resource_group.fail_no_va.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "Password1234!"
}

resource "azurerm_resource_group" "fail_bad_va" {
  name     = "rg-bad-va"
  location = "East US"
}

resource "azurerm_mssql_server" "fail_bad_va" {
  name                         = "sqlserver-bad-va"
  resource_group_name          = azurerm_resource_group.fail_bad_va.name
  location                     = azurerm_resource_group.fail_bad_va.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "Password1234!"
}

resource "azurerm_mssql_server_vulnerability_assessment" "fail_bad_va" {
  server_id = azurerm_mssql_server.fail_bad_va.id

  storage_container_path = ""

  recurring_scans {
    enabled                   = false
    email_subscription_admins = false
  }
}

resource "azurerm_resource_group" "fail_no_email" {
  name     = "rg-no-email"
  location = "East US"
}

resource "azurerm_mssql_server" "fail_no_email" {
  name                         = "sqlserver-no-email"
  resource_group_name          = azurerm_resource_group.fail_no_email.name
  location                     = azurerm_resource_group.fail_no_email.location
  version                      = "12.0"
  administrator_login          = "adminuser"
  administrator_login_password = "Password1234!"
}

resource "azurerm_mssql_server_vulnerability_assessment" "fail_no_email" {
  server_id = azurerm_mssql_server.fail_no_email.id

  storage_container_path = "https://storage.blob.core.windows.net/va"

  recurring_scans {
    enabled                   = true
    email_subscription_admins = false
    email_addresses           = [] 
  }
}
