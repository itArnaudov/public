provider "azurerm" {
  features {}
}

# Resource group for the App Service Environment and Plan
resource "azurerm_resource_group" "iAr" {
  name     = "iAr-resources"
  location = "West Europe"
}

# Virtual Network for ASE Subnet
resource "azurerm_virtual_network" "iAr" {
  name                = "iAr-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.iAr.location
  resource_group_name = azurerm_resource_group.iAr.name
}

# Subnet for ASE
resource "azurerm_subnet" "iAr" {
  name                 = "ase-subnet"
  resource_group_name  = azurerm_resource_group.iAr.name
  virtual_network_name = azurerm_virtual_network.iAr.name
  address_prefixes     = ["10.0.1.0/24"]
  delegation {
    name = "ase-delegation"
    service_delegation {
      name = "Microsoft.Web/hostingEnvironments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
      ]
    }
  }
}

# App Service Environment (ASE)
resource "azurerm_app_service_environment_v3" "iAr" {
  name                         = "iAr-ase"
  resource_group_name          = azurerm_resource_group.iAr.name
  location                     = azurerm_resource_group.iAr.location
  subnet_id                    = azurerm_subnet.iAr.id
  zone_redundant               = false
  internal_load_balancing_mode = "Web"
}

#
