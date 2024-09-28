#24
//going to delete this file. azurerm changes causing the sample below to be fundamentally wrong and needing a complete rebuild. 
//submitting a new sample file that also includes underlying vnet and couple of vms attached to it, for better representation of this excersise 
//thank you.  
#
provider "azurerm" {
  features {}
}

# Resource group
resource "azurerm_resource_group" "example" {
  name     = "my-resource-group"
  location = "West US"
}

# Virtual network
resource "azurerm_virtual_network" "example" {
  name                = "my-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# Subnet
resource "azurerm_subnet" "example" {
  name                 = "my-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}

# Load Balancer (Internal)
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
    frontend_ip_configuration = "internal-ip"
    frontend_port             = 80
    backend_port              = 80
    protocol                  = "Tcp"
    backend_address_pool_id   = azurerm_lb.internal.backend_address_pool[0].id
    probe_id                  = azurerm_lb.internal.probe[0].id
  }
}

# Data block to retrieve existing storage account (for boot diagnostics)
data "azurerm_storage_account" "example" {
  name                = "my-storage-account" # Replace with your actual storage account name
  resource_group_name = azurerm_resource_group.example.name
}

# Network interface for the VMs
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

# Virtual Machines
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

  boot_diagnostics {
    storage_account_uri = data.azurerm_storage_account.example.primary_blob_endpoint
  }

  tags = {
    environment = "production"
  }
}
#
