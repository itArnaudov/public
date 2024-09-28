provider "azurerm" {
  features {}
}

# Resource group for the App Service Environment, Plan, and Key Vault
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

# Azure Key Vault
resource "azurerm_key_vault" "iAr" {
  name                = "iAr-keyvault"
  location            = azurerm_resource_group.iAr.location
  resource_group_name = azurerm_resource_group.iAr.name
  tenant_id           = "<tenant-id>" # Replace with your Azure Tenant ID
  sku_name            = "standard"

  # Access policies can be added to allow app to retrieve the certificate
  access_policy {
    tenant_id               = "<tenant-id>"     # Replace with your Azure Tenant ID
    object_id               = "<app-object-id>" # Replace with the object ID of the App Service
    key_permissions         = ["get"]
    secret_permissions      = ["get"]
    certificate_permissions = ["get"]
  }
}

# Retrieve certificate from Key Vault
resource "azurerm_key_vault_certificate" "iAr" {
  name         = "iAr-cert"
  key_vault_id = azurerm_key_vault.iAr.id
  certificate {
    name         = "api-iArOps-cert"
    content_type = "application/x-pkcs12"
    pfx_base64   = "<base64-encoded-certificate>" # Replace with the actual base64 encoded certificate (from Key Vault)
    password     = "<cert-password>"              # Replace with the PFX password if required
  }
}

# App Service with custom domain and SSL binding
resource "azurerm_app_service" "iAr" {
  name                = "iAr-app-service"
  location            = azurerm_resource_group.iAr.location
  resource_group_name = azurerm_resource_group.iAr.name
  app_service_plan_id = azurerm_app_service_plan.iAr.id

  site_config {
    always_on             = true
    http2_enabled         = true
    managed_pipeline_mode = "Integrated"

    # SSL Binding for Custom Domain
    ssl_binding {
      certificate_thumbprint = azurerm_key_vault_certificate.iAr.id
      ssl_state              = "SniEnabled"
      name                   = "api.iArOps.com" # Custom domain
    }

    # Custom Hostname
    custom_domain_verification_id = "api.iArOps.com" # Custom domain hostname
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }

  https_only = true

  # Custom Domain Binding
  custom_domain {
    name           = "api.iArOps.com"
    certificate_id = azurerm_key_vault_certificate.iAr.id
  }
}

# DNS zone for iArOps.com (if applicable)
resource "azurerm_dns_zone" "iAr" {
  name                = "iArOps.com"
  resource_group_name = azurerm_resource_group.iAr.name
}

# CNAME Record for api.iArOps.com (optional, DNS setup)
resource "azurerm_dns_cname_record" "iAr-api" {
  name                = "api"
  zone_name           = azurerm_dns_zone.iAr.name
  resource_group_name = azurerm_resource_group.iAr.name
  ttl                 = 300
  record              = azurerm_app_service.iAr.default_site_hostname
}

#
