# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "iAr-sftp_rg" {
  name     = "iAr-sftp-rg"
  location = "West Europe"
}

# Create the SFTP storage account with module
module "sftp_storage" {
  source  = "claranet/terraform-azurerm-storage-sftp"
  version = "~> 2.0.0"

  name                = "iAr-sftp-storage"
  resource_group_name = azurerm_resource_group.iAr-sftp_rg.name
  location            = azurerm_resource_group.iAr-sftp_rg.location
  container_names     = ["iAr-sftp-container"]
}

# Access the generated outputs (including username, password)
output "iAr_sftp_users" {
  value = module.sftp_storage.storage_sftp_users
}

# Use the provided username and password for your SFTP clients

# Create the storage account
resource "azurerm_storage_account" "iAr-sftp_storage" {
  name                     = "iAr-sftp-storage"
  resource_group_name      = azurerm_resource_group.iAr-sftp_rg.name
  location                 = azurerm_resource_group.iAr-sftp_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  # Enable SFTP in the post-deployment script
  lifecycle {
    post_up {
      inline = <<EOT
      az storage account update --resource-group ${azurerm_storage_account.iAr-sftp_storage.resource_group_name} --name ${azurerm_storage_account.iAr-sftp_storage.name} --enable-sftp-endpoint
      EOT
    }
  }
}

# Create a container (replace with your script for user management)
resource "azurerm_storage_container" "iAr-sftp_container" {
  name                 = "iAr-sftp-container"
  resource_group_name  = azurerm_storage_account.iAr-sftp_storage.resource_group_name
  storage_account_name = azurerm_storage_account.iAr-sftp_storage.name
}

# Replace this placeholder with your Azure CLI or PowerShell script for managing SFTP users
resource "null_resource" "iAr_sftp_users" {
  source = "your-sftp-user-management-script.sh"
}
