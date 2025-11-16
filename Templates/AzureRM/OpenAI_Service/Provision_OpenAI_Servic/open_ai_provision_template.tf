provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "rg-openai-demo"
  location = "eastus"

  tags = {
    Environment = "dev"
    Owner       = "hemanth"
    project     = "azure-openai"
    Reason = "testing"
  }
}

resource "azurerm_cognitive_account" "openai_1" {
  name                = "openai_1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  kind     = "OpenAI"
  sku_name = "S0"

  custom_subdomain_name         = "openaiacctdemo123"
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags =  {
    Environment = "dev"
    Owner       = "hemanth"
    project     = "azure-openai"
    Reason = "testing"
  }
}

resource "azurerm_cognitive_account" "openai_2" {
  name                = "openai_2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  kind     = "OpenAI"
  sku_name = "S0"

  custom_subdomain_name         = "openaiacctdemo123"
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags =  {
    Environment = "dev"
    Owner       = "hemanth"
    project     = "azure-openai"
    Reason = "testing"
  }
}

resource "azurerm_cognitive_deployment" "deployment" {
  name                       = "gpt4deployment"
  cognitive_account_id       = azurerm_cognitive_account.openai_1.id
  dynamic_throttling_enabled = true
  version_upgrade_option     = "OnceNewDefaultVersionAvailable"

  model {
    format  = "OpenAI"
    name    = "o1-mini"
    version = "10"
  }

  sku {
    name = "ProvisionedManaged"
    capacity = 25  # <-- PTU count (1000 TPM per unit)
    tier = "Standard"
  }
}