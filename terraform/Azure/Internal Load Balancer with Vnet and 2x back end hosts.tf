#24
//going to delete this file. azurerm changes causing the sample below to be fundamentally wrong and needing a complete rebuild. 
//submitting a new sample file that also includes underlying vnet and couple of vms attached to it, for better representation of this excersise 
//thank you.  
#
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "West US"
}

resource "azurerm_virtual_network" "example" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_lb" "internal" {
  name                = "my-internal-lb"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "internal-ip"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.4"
  }

  backend_address_pool {
    name = "backend-pool"
  }

  probe {
    name                = "tcp-probe"
    protocol            = "Tcp"
    port                = 80
    interval_in_seconds = 5
    number_of_probes    = 2
  }

  load_balancing_rule {
    name                      = "lb-rule"
    frontend_port             = 80
    backend_port              = 80
    protocol                  = "Tcp"
    frontend_ip_configuration = azurerm_lb.internal.frontend_ip_configuration[0].name
    backend_address_pool      = azurerm_lb.internal.backend_address_pool[0].name
    probe                     = azurerm_lb.internal.probe[0].name
  }
}

data "azurerm_storage_account" "example" {
  name                = "<storage_account_name>"
  resource_group_name = "<storage_account_resource_group>"
}

resource "azurerm_network_interface" "example" {
  count               = 2
  name                = "my-nic-${count.index}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "my-ip-config"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "example" {
  count                 = 2
  name                  = "my-vm-${count.index}"
  location              = azurerm_resource_group.example.location
  resource_group_name   = azurerm_resource_group.example.name
  network_interface_ids = [azurerm_network_interface.example[count.index].id]
  vm_size               = "Standard_DS2_v2"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "myvm${count.index}"
    admin_username = "adminuser"
    admin_password = "P@ssword1234!"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }

  #  boot_diagnostics {
  #    enabled            = true
  #    storage_account_uri = data.azurerm_storage_account.example
  #  }

  boot_diagnostics {
    enabled             = true
    storage_account_uri = azurerm_storage_account.example.primary_blob_endpoint
  }

  tags = {
    environment = "production"
  }
}

