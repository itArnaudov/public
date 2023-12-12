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

# Create a subnet
resource "azurerm_subnet" "iAr" {
  name                 = var.subnet_name
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
    subnet_id          = azurerm_subnet.iAr.id
  }
}

# Create a backend pool
resource "azurerm_lb_backend_pool" "iAr" {
  name                = var.backend_pool_name
  resource_group_name = azurerm_resource_group.iAr.name
  loadbalancer_id     = azurerm_lb.iAr.id
}

# Create a load balancing rule
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

# Create a health probe
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
#
#=========================================================================================
#
