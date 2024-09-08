# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "iAr-sftp_rg" {
  name     = "iAr-sftp-rg"
  location = "West Europe"
}

# Create the storage account with required arguments
resource "azurerm_storage_account" "iAr-sftp_storage" {
  name                     = "iAr-sftp-storage"
  resource_group_name      = azurerm_resource_group.iAr-sftp_rg.name
  location                 = azurerm_resource_group.iAr-sftp_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = true

  # Enable SFTP in the post-deployment script
  lifecycle {
    #post_up {
    #  inline = <<EOT
    #  az storage account update --resource-group ${azurerm_storage_account.iAr-sftp_storage.resource_group_name} --name ${azurerm_storage_account.iAr-sftp_storage.name} --enable-sftp-endpoint
    #  EOT
  }
}
#}

# Create a container after the storage account is available
resource "azurerm_storage_container" "iAr-sftp_container" {
  name = "iAr-sftp-container"
  #resource_group_name       = azurerm_storage_account.iAr-sftp_storage.resource_group_name
  storage_account_name = azurerm_storage_account.iAr-sftp_storage.name

  # Depends on azurerm_storage_account.iAr-sftp_storage to ensure creation after storage exists
  depends_on = [azurerm_storage_account.iAr-sftp_storage]
}

# Manage SFTP users with an external script (not Terraform)
resource "null_resource" "iAr_sftp_users" {
  #source = "your-sftp-user-management-script.sh"
}

