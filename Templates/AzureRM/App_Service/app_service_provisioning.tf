provider "azurerm" {
  features {}
}

locals {
  location            = "eastus"
  resource_group_name = "rg-appservice-demo"
  tags_dev = {
    environment = "dev"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_service_plan" "plan_premium" {
  name                = "appserviceplan-dev-premium"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  sku {
    tier = "Premium"
    size = "P1v2"
  }

  tags = local.tags_dev
  sku_name = ""
}

resource "azurerm_service_plan" "plan_standard" {
  name                = "appserviceplan-dev-standard"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"

  sku {
    tier = "Standard"
    size = "S1"
  }

  tags = local.tags_dev
  sku_name = ""
}