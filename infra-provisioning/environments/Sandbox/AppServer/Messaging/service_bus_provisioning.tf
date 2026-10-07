locals {
  prefix = "${var.project}-${var.environment}"
   tags = {
    Environment = "Sandbox"
    Owner = "VE"
  }
}
resource "azurerm_resource_group" "this" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_servicebus_namespace" "this" {
  name                = "sb-${local.prefix}-${random_string.suffix.result}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_servicebus_queue" "this" {
  name         = "${local.prefix}-queue"
  namespace_id = azurerm_servicebus_namespace.this.id
}
