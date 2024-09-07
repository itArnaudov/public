# App Service Plan in the ASE
resource "azurerm_app_service_plan" "iAr" {
  name                = "iAr-app-service-plan"
  location            = azurerm_resource_group.iAr.location
  resource_group_name = azurerm_resource_group.iAr.name
  kind                = "App"

  sku {
    tier = "IsolatedV2"
    size = "I2"
  }

  app_service_environment_id = azurerm_app_service_environment_v3.iAr.id
}

#
