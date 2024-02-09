resource "azurerm_resource_group" "iAr-function_app_rg" {
  name     = "iAr-function-app-rg"
  location = "West Europe"
}

resource "azurerm_app_service_plan" "iAr-function_app_plan" {
  name                = "iAr-function-app-plan"
  resource_group_name = azurerm_resource_group.iAr-function_app_rg.name
  location            = azurerm_resource_group.iAr-function_app_rg.location
  sku {
    tier = "Standard"
    size = "B1"
  }
}

resource "azurerm_function_app" "iAr-function_app" {
  name                = "iAr-function-app"
  resource_group_name = azurerm_resource_group.iAr-function_app_rg.name
  location            = azurerm_resource_group.iAr-function_app_rg.location
  app_service_plan_id = azurerm_app_service_plan.iAr-function_app_plan.id
  operating_system    = "Windows"
  runtime_version     = "PowerShell"
  is_linux            = false
}

