provider "azurerm" {
  features {}
}

variable "resource_group_name" {
  default = "my-resource-group-1"
}

variable "location" {
  default = "westus"
}

variable "subnet_name" {
  default = "internal-subnet"
}

variable "lb_name" {
  default = "internal-lb"
}

variable "backend_pool_name" {
  default = "backend-pool"
}

variable "lb_rule_name" {
  default = "lb-rule"
}

variable "app_gateway_name" {
  default = "internal-app-gateway"
}

variable "vm_count" {
  default = 2
}

# Create a resource group
resource "azurerm_resource_group" "iAr" {
  name     = var.resource_group_name
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "iAr" {
  name                = "internal-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.iAr.location
  resource_group_name = azurerm_resource_group.iAr.name
}

# Create a subnet for the internal load balancer
resource "azurerm_subnet" "lb_subnet" {
  name                 = "internal-lb-subnet"
  resource_group_name  = azurerm_resource_group.iAr.name
  virtual_network_name = azurerm_virtual_network.iAr.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create an internal load balancer
resource "azurerm_lb" "iAr" {
  name                = var.lb_name
  resource_group_name = azurerm_resource_group.iAr.name
  location            = azurerm_resource_group.iAr.location
  sku                 = "Standard"
  frontend_ip_configuration {
    name               = "internal"
    private_ip_address = "10.0.1.4" # Change this to your desired private IP address
    subnet_id          = azurerm_subnet.lb_subnet.id
  }
}

# Create a backend pool for the internal load balancer
resource "azurerm_lb_backend_pool" "iAr" {
  name                = var.backend_pool_name
  resource_group_name = azurerm_resource_group.iAr.name
  loadbalancer_id     = azurerm_lb.iAr.id
}

# Create virtual machines for the backend pool
resource "azurerm_windows_virtual_machine" "iAr" {
  count               = var.vm_count
  name                = "vm-${count.index}"
  resource_group_name = azurerm_resource_group.iAr.name
  location            = azurerm_resource_group.iAr.location
  size                = "Standard_DS1_v2" # Change this to your desired VM size
  admin_username      = "adminuser"
  admin_password      = "AdminPassword123!" # Change this to your desired password

  network_interface_ids = [azurerm_network_interface.iAr[count.index].id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}

# Create network interfaces for virtual machines
resource "azurerm_network_interface" "iAr" {
  count               = var.vm_count
  name                = "nic-${count.index}"
  location            = azurerm_resource_group.iAr.location
  resource_group_name = azurerm_resource_group.iAr.name

  ip_configuration {
    name                          = "internal-nic-${count.index}"
    subnet_id                     = azurerm_subnet.lb_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create a load balancing rule for the internal load balancer
resource "azurerm_lb_rule" "iAr" {
  name = var.lb_rule_name
  //resource_group_name   = azurerm_resource_group.iAr.name
  loadbalancer_id                = azurerm_lb.iAr.id
  frontend_ip_configuration_name = azurerm_lb.iAr.frontend_ip_configuration[0].name
  frontend_ip_configuration_id   = azurerm_lb.iAr.frontend_ip_configuration[0].id
  //backend_address_pool_id      = azurerm_lb_backend_pool.iAr.id
  probe_id      = azurerm_lb_probe.iAr.id
  protocol      = "Tcp"
  frontend_port = 80
  backend_port  = 80
}

# Create a health probe for the internal load balancer
resource "azurerm_lb_probe" "iAr" {
  name = "health-probe"
  //resource_group_name   = azurerm_resource_group.iAr.name
  loadbalancer_id = azurerm_lb.iAr.id
  protocol        = "Tcp"
  port            = 80
  request_path    = "/"
  //interval              = 5
  //unhealthy_threshold   = 2
}

# Create a subnet for the application gateway
resource "azurerm_subnet" "app_gateway_subnet" {
  name                 = "app-gateway-subnet"
  resource_group_name  = azurerm_resource_group.iAr.name
  virtual_network_name = azurerm_virtual_network.iAr.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Create an application gateway
resource "azurerm_application_gateway" "iAr" {
  name                = var.app_gateway_name
  resource_group_name = azurerm_resource_group.iAr.name
  location            = azurerm_resource_group.iAr.location
  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "app-gateway-ip-configuration"
    subnet_id = azurerm_subnet.app_gateway_subnet.id
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "app-gateway-frontend-ip"
    public_ip_address_id = null       # This is an internal application gateway, so no public IP is associated
    private_ip_address   = "10.0.2.4" # Change this to your desired private IP address
    subnet_id            = azurerm_subnet.app_gateway_subnet.id
    //private_ip_address_allocations = ["Static"]
  }

  backend_address_pool {
    name = "app-gateway-backend-pool"
    backend_address {
      ip_address = azurerm_windows_virtual_machine.iAr[0].network_interface_ids[0].private_ip_address
    }
    backend_address {
      ip_address = azurerm_windows_virtual_machine.iAr[1].network_interface_ids[0].private_ip_address
    }
  }

  backend_http_settings {
    name                  = "app-gateway-backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 30
  }

  http_listener {
    name                           = "app-gateway-http-listener"
    frontend_ip_configuration_name = "app-gateway-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "app-gateway-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = azurerm_application_gateway.iAr.http_listener[0].name
    backend_address_pool_name  = azurerm_application_gateway.iAr.backend_address_pool[0].name
    backend_http_settings_name = azurerm_application_gateway.iAr.backend_http_settings[0].name
  }
}
#
