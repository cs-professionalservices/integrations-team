provider "azurerm" {
  features {}
}

# ⚙️ Modify these values as needed
locals {
  resource_group_name = "rg-openai-demo"
  location            = "eastus"
  openai_account_name = "myopenaiaccount123"
  deployment_name     = "gpt4deployment"
  model_name          = "gpt-4"
  model_version       = "0613"
  ptu_count           = 3
  tags = {
    environment = "dev"
    project     = "azure-openai"
  }
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_cognitive_account" "openai" {
  name                = local.openai_account_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  kind     = "OpenAI"
  sku_name = "S0"

  custom_subdomain_name         = local.openai_account_name
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

resource "azurerm_cognitive_deployment" "deployment" {
  name                 = local.deployment_name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    format  = "OpenAI"
    name    = local.model_name
    version = local.model_version
  }

  scale {
    type     = "Premium"
    capacity = local.ptu_count
  }
}

output "openai_endpoint" {
  value = azurerm_cognitive_account.openai.endpoint
}

output "deployment_name" {
  value = azurerm_cognitive_deployment.deployment.name
}
