locals {
  prefix = "${var.project}-${var.environment}"
    tags = {
    Environment = "Sandbox"
  }

  subnets = merge(
    {
      web = cidrsubnet(var.address_space, 8, 1)
      db  = cidrsubnet(var.address_space, 8, 3)
    },
    var.enable_app_tier ? { app = cidrsubnet(var.address_space, 8, 2) } : {}
  )

  app_tier_clients = [for k, v in local.subnets : v if k != "db"]  # web (+ app)
  mongo_clients    = [lookup(local.subnets, "app", local.subnets.web)] # who may talk to MongoDB

  linux_vms = merge(
    { web = { subnet = "web", size = var.vm_size } },
    var.enable_app_tier ? { app = { subnet = "app", size = var.vm_size } } : {},
    { mongo = { subnet = "db", size = var.db_vm_size } }
  )

  deny_all = { name = "deny-all-inbound", priority = 4000, access = "Deny", ports = ["*"], sources = ["*"] }

  nsg_rules = {
    web = [
      { name = "allow-http-https", priority = 100, access = "Allow", ports = ["80", "443"], sources = ["Internet"] },
      { name = "allow-ssh-admin", priority = 110, access = "Allow", ports = ["22"], sources = [var.admin_cidr] },
      local.deny_all,
    ]
    app = [
      { name = "allow-app-from-web", priority = 100, access = "Allow", ports = ["8080"], sources = [local.subnets.web] },
      { name = "allow-ssh-from-web", priority = 110, access = "Allow", ports = ["22"], sources = [local.subnets.web] },
      local.deny_all,
    ]
    db = [
      { name = "allow-mongo", priority = 100, access = "Allow", ports = ["27017"], sources = local.mongo_clients },
      { name = "allow-mssql", priority = 110, access = "Allow", ports = ["1433"], sources = concat(local.app_tier_clients, var.powerbi_cidrs) },
      { name = "allow-ssh-internal", priority = 120, access = "Allow", ports = ["22"], sources = local.app_tier_clients },
      { name = "allow-rdp-admin", priority = 130, access = "Allow", ports = ["3389"], sources = [var.admin_cidr] },
      local.deny_all,
    ]
  }
}


resource "azurerm_resource_group" "this" {
  name     = "rg-${local.prefix}"
  location = var.location
  tags     = local.tags
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${local.prefix}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  address_space       = [var.address_space]
  tags                = local.tags
}

resource "azurerm_subnet" "this" {
  for_each             = local.subnets
  name                 = "snet-${each.key}"
  resource_group_name  = azurerm_resource_group.this.name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value]
}

resource "azurerm_network_security_group" "this" {
  for_each            = local.subnets
  name                = "nsg-${local.prefix}-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  dynamic "security_rule" {
    for_each = local.nsg_rules[each.key]
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = "Inbound"
      access                     = security_rule.value.access
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_ranges    = security_rule.value.ports
      source_address_prefixes    = security_rule.value.sources
      destination_address_prefix = "*"
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = local.subnets
  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}

resource "azurerm_public_ip" "web" {
  name                = "pip-${local.prefix}-web"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}
