provider "azurerm" {
  features = {}
}

resource "azurerm_resource_group" "iAr" {
  name     = "iAr-sftp-rg"
  location = "East US"  # Change to your desired Azure region
}

resource "azurerm_virtual_network" "iAr" {
  name                = "iAr-sftp-vnet"
  resource_group_name = azurerm_resource_group.iAr.name
  location            = azurerm_resource_group.iAr.location
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "iAr" {
  name                 = "iAr-sftp-subnet"
  resource_group_name  = azurerm_resource_group.iAr.name
  virtual_network_name = azurerm_virtual_network.iAr.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "iAr" {
  name                = "iAr-sftp-nic"
  resource_group_name = azurerm_resource_group.iAr.name

  ip_configuration {
    name                          = "iAr-sftp-ip"
    subnet_id                     = azurerm_subnet.iAr.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "iAr" {
  name                = "iAr-sftp-vm"
  resource_group_name = azurerm_resource_group.iAr.name
  location            = azurerm_resource_group.iAr.location
  size                = "Standard_DS1_v2"  # Change to your desired VM size
  admin_username      = "iarsftpadmin"
  admin_password      = "SuperSecretPassword123!"  # Change to your desired password

  network_interface_ids = [azurerm_network_interface.iAr.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7.7"
    version   = "latest"
  }

  custom_data = <<EOF
#!/bin/bash
yum -y install openssh-server
systemctl enable sshd
systemctl start sshd
EOF
}

resource "azurerm_network_security_group" "iAr_nsg" {
  name                = "iAr-sftp-nsg"
  resource_group_name = azurerm_resource_group.iAr.name

  security_rule {
    name                       = "iAr-SFTP-AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = 22
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "iAr_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.iAr.id
  network_security_group_id = azurerm_network_security_group.iAr_nsg.id
}

resource "azurerm_key_vault" "iAr_kv" {
  name                        = "iAr-sftp-keyvault"
  resource_group_name         = azurerm_resource_group.iAr.name
  location                    = azurerm_resource_group.iAr.location
  enabled_for_disk_encryption = false
  enabled_for_deployment      = true
  enabled_for_template_deployment = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
}

resource "azurerm_key_vault_secret" "iAr_cert_secret" {
  name         = "iAr-sftp-cert"
  value        = filebase64("path/to/your/certificate.pem")  # Change to the path of your certificate
  key_vault_id = azurerm_key_vault.iAr_kv.id
}

resource "azurerm_linux_virtual_machine_certificate" "iAr_cert" {
  name                = "iAr-sftp-cert"
  virtual_machine_id  = azurerm_linux_virtual_machine.iAr.id
  key_vault_secret_id = azurerm_key_vault_secret.iAr_cert_secret.id
}
