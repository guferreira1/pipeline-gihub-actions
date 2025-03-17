resource "azurerm_resource_group" "rg" {
  location = "Brazil South"
  name     = "rg-vm"

  tags = local.common_tags
}

resource "azurerm_public_ip" "ip" {
  name                = "public-ip-terraform"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"

  tags = local.common_tags
}

resource "azurerm_network_interface" "nic" {
  location            = azurerm_resource_group.rg.location
  name                = "nic-terraform"
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "public-ip-terraform"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = data.terraform_remote_state.vnet.outputs.subnet-id
    public_ip_address_id          = azurerm_public_ip.ip.id
  }

  tags = local.common_tags
}

resource "azurerm_network_interface_security_group_association" "nisga" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = data.terraform_remote_state.vnet.outputs.security-group-id
}

resource "azurerm_linux_virtual_machine" "vm" {
  admin_username        = "terraform"
  location              = azurerm_resource_group.rg.location
  name                  = "vm-terraform"
  network_interface_ids = [azurerm_network_interface.nic.id]
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B1s"

  admin_ssh_key {
    public_key = var.azure_key_pub
    username   = "terraform"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    offer     = "0001-com-ubuntu-server-jammy"
    publisher = "canonical"
    sku       = "22_04-lts"
    version   = "latest"
  }

  tags = local.common_tags
}