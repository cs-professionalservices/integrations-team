resource "azurerm_network_interface" "linux" {
  for_each            = local.linux_vms
  name                = "nic-${local.prefix}-${each.key}"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  tags                = local.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.this[each.value.subnet].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = each.key == "web" ? azurerm_public_ip.web.id : null
  }
}

resource "azurerm_linux_virtual_machine" "linux" {
  for_each              = local.linux_vms
  name                  = "vm-${local.prefix}-${each.key}"
  computer_name         = "${each.key}-${var.environment}"
  location              = azurerm_resource_group.this.location
  resource_group_name   = azurerm_resource_group.this.name
  size                  = each.value.size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.linux[each.key].id]
  tags                  = merge(local.tags, { Tier = each.key })

  disable_password_authentication = true
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = each.key == "mongo" ? 128 : 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # MongoDB is installed only on the dedicated DB VM
  custom_data = each.key == "mongo" ? base64encode(templatefile("${path.module}/../../scripts/install_mongo.sh.tftpl", {
    bind_ip = "0.0.0.0" # reachable only from allowed subnets via NSG
  })) : null
}