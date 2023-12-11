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

resource "azurerm_lb" "internal" {
  name                = "my-internal-lb"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "internal-ip"
    subnet_id                     = "/subscriptions/subscription-id/resourceGroups/my-resource-group/providers/Microsoft.Network/virtualNetworks/my-vnet/subnets/my-subnet"
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.0.4"
  }
}
resource "azurerm_lb_backend_address_pool" "internal_bep" {
    loadbalancer_id = azurerm_lb.internal.id
    name = "ilb-backend-pool"
}
resource "azurerm_lb_backend_address_pool_backend_address" "internal_bep_ba" {
  name = "internal-backendpool-address"
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id = azurerm_lb.internal.id
  backend_address_pool_id = azurerm_lb_backend_address_pool.internal_bep.id
  ip_configuration_id = 
}


#   backend_address_pool {
#     name = "backend-pool"
#   }

#   probe {
#     name                = "tcp-probe"
#     protocol            = "Tcp"
#     port                = 80
#     interval_in_seconds = 5
#     number_of_probes    = 2
#   }

#   load_balancing_rule {
#     name                      = "lb-rule"
#     frontend_port             = 80
#     backend_port              = 80
#     protocol                  = "Tcp"
#     frontend_ip_configuration = azurerm_lb.internal.frontend_ip_configuration[0].name
#     backend_address_pool      = azurerm_lb.internal.backend_address_pool[0].name
#     probe                     = azurerm_lb.internal.probe[0].name
#   }
# }
#
