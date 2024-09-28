# App Service using the App Service Plan in the ASE
resource "azurerm_app_service" "iAr" {
  name                = "iAr-app-service"
  location            = azurerm_resource_group.iAr.location
  resource_group_name = azurerm_resource_group.iAr.name
  app_service_plan_id = azurerm_app_service_plan.iAr.id

  site_config {
    always_on             = true
    http2_enabled         = true
    managed_pipeline_mode = "Integrated"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  https_only = true
}

#
