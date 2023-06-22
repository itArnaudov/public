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
    name                      = "tcp-probe"
    protocol                  = "Tcp"
    port                      = 80
    interval_in_seconds       = 5
    number_of_probes          = 2
  }

  load_balancing_rule {
    name                       = "lb-rule"
    frontend_port              = 80
    backend_port               = 80
    protocol                   = "Tcp"
    frontend_ip_configuration = azurerm_lb.internal.frontend_ip_configuration[0].name
    backend_address_pool       = azurerm_lb.internal.backend_address_pool[0].name
    probe                      = azurerm_lb.internal.probe[0].name
  }
}
