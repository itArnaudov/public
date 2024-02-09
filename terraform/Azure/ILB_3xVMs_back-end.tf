provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  default = "iAr-resources"
}

variable "location" {
  default = "Central US"
}

variable "virtual_network_name" {
  default = "iAr-network"
}

variable "subnet_name" {
  default = "internal"
}

variable "network_interface_name" {
  default = "iAr-nic"
}

variable "lb_name" {
  default = "iAr-ilb"
}

variable "lb_pool_name" {
  default = "iAr-pool"
}

variable "lb_pool_backend_name" {
  default = "iAr-pool-backend"
}

variable "vm_count" {
  default = 3
}

// Resource Group
resource "azurerm_resource_group" "iAr" {
  name     = var.resource_group_name
  location = var.location
}

// Virtual Network
resource "azurerm_virtual_network" "iAr" {
  name                = var.virtual_network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.iAr.location
  resource_group_name = azurerm_resource_group.iAr.name
}

// Subnet
resource "azurerm_subnet" "iAr" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.iAr.name
  virtual_network_name = azurerm_virtual_network.iAr.name
  address_prefixes     = ["10.0.1.0/24"]
}

// Network Interfaces
resource "azurerm_network_interface" "iAr" {
  count               = var.vm_count
  name                = "${var.network_interface_name}-${count.index}"
  location            = azurerm_resource_group.iAr.location
  resource_group_name = azurerm_resource_group.iAr.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.iAr.id
    private_ip_address_allocation = "Dynamic"
  }
}

// Virtual Machines
resource "azurerm_virtual_machine" "iAr" {
  count                 = var.vm_count
  name                  = "iAr-vm-${count.index}"
  location              = azurerm_resource_group.iAr.location
  resource_group_name   = azurerm_resource_group.iAr.name
  network_interface_ids = [azurerm_network_interface.iAr[count.index].id]

  vm_size                       = "Standard_DS1_v2"
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  storage_os_disk {
    name              = "osdisk-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "iAr-vm-${count.index}"
    admin_username = "adminuser"
    admin_password = "Password1234!"
  }

  os_profile_windows_config {
    provision_vm_agent = true
  }
}

// Load Balancer
resource "azurerm_lb" "iAr" {
  name                = var.lb_name
  resource_group_name = azurerm_resource_group.iAr.name
  location            = azurerm_resource_group.iAr.location
  sku                 = "Standard"
  frontend_ip_configuration {
    name               = "internal"
    private_ip_address = "10.0.1.4"
    subnet_id          = azurerm_subnet.iAr.id
  }
}

// Load Balancer Backend Address Pool
resource "azurerm_lb_backend_address_pool" "iAr" {
  name = var.lb_pool_name
  //resource_group_name = azurerm_resource_group.iAr.name
  loadbalancer_id = azurerm_lb.iAr.id
}

// Load Balancer Backend Address Pool Backend Addresses
resource "azurerm_lb_backend_address_pool_backend_address" "iAr" {
  count                   = var.vm_count
  name                    = "${var.lb_pool_backend_name}-${count.index}"
  resource_group_name     = azurerm_resource_group.iAr.name
  loadbalancer_id         = azurerm_lb.iAr.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.iAr.id
  ip_configuration_id     = azurerm_network_interface.iAr[count.index].ip_configuration[0].id
}

// Network Interface Backend Address Pool Association
resource "azurerm_network_interface_backend_address_pool_association" "iAr" {
  count                   = var.vm_count
  network_interface_id    = azurerm_network_interface.iAr[count.index].id
  ip_configuration_name   = azurerm_network_interface.iAr[count.index].ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.iAr.id
}
