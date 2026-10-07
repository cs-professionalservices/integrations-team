resource "azurerm_cognitive_account" "openai_public_noncompliant" {
  name                = "openai-publicaccess-noncompliant"
  location            = "East US"
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "OpenAI"

  sku_name = "S0"
  sku_tier = "Standard"

  public_network_access_enabled = true
}

resource "azurerm_cognitive_deployment" "openai_public_noncompliant" {
  name                 = "openai-publicaccess-deployment"
  cognitive_account_id = azurerm_cognitive_account.openai_public_noncompliant.id

  model {
    format  = "OpenAI"
    name    = "gpt-4"
    version = "2024-05-01"
  }

  sku {
    name     = "S0"
    capacity = 16
  }
}