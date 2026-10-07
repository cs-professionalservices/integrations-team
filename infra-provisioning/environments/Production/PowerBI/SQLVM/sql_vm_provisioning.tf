
# ---------- Windows VM with MSSQL (for Power BI) ----------
resource "azurerm_network_interface" "sql" {
  name                = "nic-${local.prefix}-sql"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this["db"].id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "sql" {
  name                  = "vm-${local.prefix}-sql"
  computer_name         = "mssql-${var.environment}"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = var.sql_vm_size
  admin_username        = var.admin_username
  admin_password        = var.sql_admin_password
  network_interface_ids = [azurerm_network_interface.sql.id]
  tags                  = merge(local.tags, { Tier = "mssql" })

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  # Marketplace image with SQL Server pre-installed
  source_image_reference {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2022-ws2022"
    sku       = "sqldev-gen2"
    version   = "latest"
  }
}

resource "azurerm_mssql_virtual_machine" "sql" {
  virtual_machine_id = azurerm_windows_virtual_machine.sql.id
  sql_license_type   = "PAYG"
  tags               = local.tags
}
