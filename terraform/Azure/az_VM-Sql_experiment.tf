#experimental code, use with caution !!! 
# License
#The code provided in this document is copyright free 2023.
#Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

provider "azurerm" {
  features {}
  version = ">= 2.0.0"
}

resource "azurerm_resource_group" "iAr-app-01-RG" {
  name     = "iAr-app-01-RG"
  location = "westus"
}

resource "azurerm_virtual_network" "iAr-app01-vnet" {
  name                      = "iAr-app01-vnet"
  location                  = azurerm_resource_group.iAr-app-01-RG.location
  address_space             = ["10.0.0.0/16"]
  resource_group_id        = azurerm_resource_group.iAr-app-01-RG.id
  subnet_name_prefix       = "subnet"
  private_endpoint_subnet              = true
}

resource "azurerm_subnet" "iAr-app01-subnet" {
  name                     = "iAr-app01-subnet"
  resource_group_id       = azurerm_resource_group.iAr-app-01-RG.id
  virtual_network_id     = azurerm_virtual_network.iAr-app01-vnet.id
  address_prefix           = "10.0.1.0/24"
}

resource "azurerm_network_interface" "iAr-app01-nic" {
  name                       = "iAr-app01-nic"
  resource_group_id        = azurerm_resource_group.iAr-app-01-RG.id
  virtual_network_id     = azurerm_virtual_network.iAr-app01-vnet.id
  subnet_id                  = azurerm_subnet.iAr-app01-subnet.id
}

resource "azurerm_virtual_machine" "iAr-app01-vm" {
  name                    = "iAr-app01-vm"
  resource_group_id       = azurerm_resource_group.iAr-app-01-RG.id
  network_interface_id   = azurerm_network_interface.iAr-app01-nic.id
  vm_size                 = "Standard_D2s_v3"
  
  # Create a second disk named "F:" and attaches it to the virtual machine
  additional_disks {
    name              = "F"
    disk_size_gb      = 1024
    storage_account_type = "Premium_LRS"
    attach_type       = "New"
  }

  # Install latest SQL Server
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y msodbcsql17 mssql-tools",
    ]
  }

  # Create database instance named "iAr-App-01_Master_DB"
  provisioner "local-exec" {
    inline = [
      "ssh -i iAr-app-01-key.pem azureuser@iAr-app01-vm 'sudo service mssql-server restart'",
      "ssh -i iAr-app-01-key.pem azureuser@iAr-app01-vm 'CREATE DATABASE iAr-App-01_Master_DB'",
    ]
  }

  # Grant user1 modify access and user21 owner access
  provisioner "remote-exec" {
    inline = [
      "sudo su - mssql",
      "CREATE USER user1 WITH PASSWORD = 'password'",
      "GRANT MODIFY ON SCHEMA dbo TO user1",
      "CREATE USER user21 WITH PASSWORD = 'password'",
      "GRANT OWNER ON DATABASE iAr-App-01_Master_DB TO user21",
    ]
  }

  # Add SQL Server maintenance plan
  provisioner "local-exec" {
    inline = [
      "ssh -i iAr-app-01-key.pem azureuser@iAr-app01-vm 'sudo /opt/m
# Add storage account
resource "azurerm_storage_account" "iAr-app-01-storage" {
  name                  = "iAr-app-01-storage"
  resource_group_id    = azurerm_resource_group.iAr-app-01-RG.id
  location              = azurerm_resource_group.iAr-app-01-RG.location
  account_tier           = "Standard"
  account_replication_type = "LRS"
}

# Create a container named "backups" in the storage account
resource "azurerm_storage_container" "iAr-app-01-backups" {
  name                = "backups"
  storage_account_id = azurerm_storage_account.iAr-app-01-storage.id
}

# Add SQL Server maintenance plan that will schedule backups to the "F:" disk
provisioner "local-exec" {
  inline = [
    "ssh -i iAr-app-01-key.pem azureuser@iAr-app01-vm 'sudo /opt/mssql-tools/bin/sqlcmd -i scripts/backup_plan_script.sql'",
  ]
}
}

#
#------------------- v1.1 -------------------
#

provider "azurerm" {
  features {}
  version = ">= 2.0.0"
}

resource "azurerm_resource_group" "iAr-app-01-RG" {
  name     = "iAr-app-01-RG"
  location = "westus"
}

 resource "azurerm_storage_account" "iAr-app-01-storage" {
  name                 = "iAr-app-01-storage"
  resource_group_id    = azurerm_resource_group.iAr-app-01-RG.id
  location              = azurerm_resource_group.iAr-app-01-RG.location
  account_tier           = "Standard"
  account_replication_type = "LRS"
}


 resource "azurerm_storage_container" "iAr-app-01-backups" {
  name                = "backups"
  storage_account_id = azurerm_storage_account.iAr-app-01-storage.id
}

 resource "azurerm_backup_policy" "iAr-app-01-backup" {
  name            = "iAr-app-01-backup"
  resource_group_id = azurerm_resource_group.iAr-app-01-RG.id
  storage_account_id = azurerm_storage_account.iAr-app-01-storage.id
  schedule         = "Weekly"

  policy_type         = "Full"
  retention_days      = 30

  schedule_start_time = "01:00"
  schedule_day_of_week = "Monday"
  schedule_month        = "01"
}

 # Add SQL Server maintenance plan that will schedule backups to the "F:" disk
provisioner "local-exec" {
  inline = [
    "ssh -i iAr-app-01-key.pem azureuser@iAr-app-01-vm 'sudo /opt/mssql-tools/bin/sqlcmd -i scripts/backup_plan_script.sql'",
  ]
}
}
resource "azurerm_resource_group" "iAr-app-01-RG" {
  name     = "iAr-app-01-RG"
  location = "westus"
}

 resource "azurerm_storage_account" "iAr-app-01-storage" {
  name                 = "iAr-app-01-storage"
  resource_group_id    = azurerm_resource_group.iAr-app-01-RG.id
  location              = azurerm_resource_group.iAr-app-01-RG.location
  account_tier           = "Standard"
  account_replication_type = "LRS"
}

 resource "azurerm_storage_container" "iAr-app-01-backups" {
  name                = "backups"
  storage_account_id = azurerm_storage_account.iAr-app-01-storage.id
}

resource "azurerm_backup_policy" "iAr-app-01-backup" {
  name            = "iAr-app-01-backup"
  resource_group_id = azurerm_resource_group.iAr-app-01-RG.id
  storage_account_id = azurerm_storage_account.iAr-app-01-storage.id
  schedule         = "Weekly"

  policy_type         = "Full"
  retention_days      = 30

  schedule_start_time = "01:00"
  schedule_day_of_week = "Monday"
  schedule_month        = "01"
}

 # Add SQL Server maintenance plan that will schedule backups to the "F:" disk
provisioner "local-exec" {
  inline = [
    "ssh -i iAr-app-01-key.pem azureuser@iAr-app01-vm 'sudo /opt/mssql-tools/bin/sqlcmd -i scripts/backup_plan_script.sql'",
  ]
}

# Create a virtual machine named "iAr-app01-vm" in the resource group
resource "azurerm_virtual_machine" "iAr-app01-vm" {
  name                    = "iAr-app01-vm"
  resource_group_id       = azurerm_resource_group.iAr-app-01-RG.id
  network_interface_id   = azurerm_network_interface.iAr-app01-nic.id
  vm_size                 = "Standard_D2s_v3"

  # Create a second disk named "F:" and attaches it to the virtual machine
  additional_disks {
    name              = "F"
    disk_size_gb      = 1024
    storage_account_type = "Premium_LRS"
    attach_type       = "New"
  }
}

#
#------------------- v1.2 -------------------
#

provider "azurerm" {
  features {}
  version = ">= 2.0.0"
}

resource "azurerm_resource_group" "iAr-app-01-RG" {
  name     = "iAr-app-01-RG"
  location = "westus"
}

resource "azurerm_key_vault" "iAr-app-01-key-vault" {
  name                = "iAr-app-01-key-vault"
  location            = azurerm_resource_group.iAr-app-01-RG.location
  resource_group_id    = azurerm_resource_group.iAr-app-01-RG.id
  enabled_for_disk_encryption = true

}

resource "azurerm_key_vault_access_policy" "admin-az-user1" {
  key_vault_id          = azurerm_key_vault.iAr-app-01-key-vault.id
  name                = "admin-az-user1"
  object_id           = azurerm_user_identity.admin-az-user1.id
  permissions {
    keys       = ["Get", "Create", "Delete", "Recover", "Purge", "List"]
    secrets    = ["Get", "Set", "Delete", "Backup", "Restore", "List"]
    storage    = ["Get"]
    certificates = ["Get"]
  }
}

resource "azurerm_key_vault_access_policy" "admin-az-user21" {
  key_vault_id          = azurerm_key_vault.iAr-app-01-key-vault.id
  name                = "admin-az-user21"
  object_id           = azurerm_user_identity.admin-az-user21.id
  permissions {
    secrets = ["Get", "List"]
  }
}
resource "azurerm_key_vault" "iAr-app-01-key-vault" {
  name                = "iAr-app-01-key-vault"
  location            = azurerm_resource_group.iAr-app-01-RG.location
  resource_group_id    = azurerm_resource_group.iAr-app-01-RG.id
  enabled_for_disk_encryption = true

}

resource "azurerm_key_vault_access_policy" "admin-az-user1" {
  key_vault_id          = azurerm_key_vault.iAr-app-01-key-vault.id
  name                = "admin-az-user1"
  object_id           = azurerm_user_identity.admin-az-user1.id
  permissions {
    keys       = ["Get", "Create", "Delete", "Recover", "Purge", "List"]
    secrets    = ["Get", "Set", "Delete", "Backup", "Restore", "List"]
    storage    = ["Get"]
    certificates = ["Get"]
  }
}

resource "azurerm_key_vault_access_policy" "admin-az-user21" {
  key_vault_id          = azurerm_key_vault.iAr-app-01-key-vault.id
  name                = "admin-az-user21"
  object_id           = azurerm_user_identity.admin-az-user21.id
  permissions {
    secrets = ["Get", "List"]
  }
}

# Create a virtual machine named "iAr-app01-vm" in the resource group
resource "azurerm_virtual_machine" "iAr-app01-vm" {
  name                    = "iAr-app01-vm"
  resource_group_id       = azurerm_resource_group.iAr-app-01-RG.id
  network_interface_id   = azurerm_network_interface.iAr-app01-nic.id
  vm_size                 = "Standard_D2s_v3"

  # Create a second disk named "F:" and attaches it to the virtual machine
  additional_disks {
    name              = "F"
    disk_size_gb      = 1024
    storage_account_type = "Premium_LRS"
    attach_type       = "New"
  }
}

# Grant access to the virtual machine to use the key vault
resource "azurerm_role_assignment" "vm-key-vault-access" {
  role_definition_name = "Contributor"
  scope                = azurerm_virtual_machine.iAr-app01-vm.id
}

#
#------------------- v1.3 -------------------
#

provider "azurerm" {
  features {}
  version = ">= 2.0.0"
}

resource "azurerm_resource_group" "iAr-app-01-RG" {
  name     = "iAr-app-01-RG"
  location = "westus"
}

resource "azurerm_key_vault" "iAr-app-01-key-vault" {
  name                = "iAr-app-01-key-vault"
  location            = azurerm_resource_group.iAr-app-01-RG.location
  resource_group_id    = azurerm_resource_group.iAr-app-01-RG.id
  enabled_for_disk_encryption = true

}

resource "azurerm_key_vault_access_policy" "admin-az-user1" {
  key_vault_id          = azurerm_key_vault.iAr-app-01-key-vault.id
  name                = "admin-az-user1"
  object_id           = azurerm_user_identity.admin-az-user1.id
  permissions {
    keys       = ["Get", "Create", "Delete", "Recover", "Purge", "List"]
    secrets    = ["Get", "Set", "Delete", "Backup", "Restore", "List"]
    storage    = ["Get"]
    certificates = ["Get"]
  }
}

resource "azurerm_key_vault_access_policy" "admin-az-user21" {
  key_vault_id          = azurerm_key_vault.iAr-app-01-key-vault.id
  name                = "admin-az-user21"
  object_id           = azurerm_user_identity.admin-az-user21.id
  permissions {
    secrets = ["Get", "List"]
  }
}

# Create a virtual machine named "iAr-app01-vm" in the resource group
resource "azurerm_virtual_machine" "iAr-app01-vm" {
  name                    = "iAr-app01-vm"
  resource_group_id       = azurerm_resource_group.iAr-app-01-RG.id
  network_interface_id   = azurerm_network_interface.iAr-app01-nic.id
  vm_size                 = "Standard_D2s_v3"
  
  # Create a second disk named "F:" and attaches it to the virtual machine
  additional_disks {
    name              = "F"
    disk_size_gb      = 1024
    storage_account_type = "Premium_LRS"
    attach_type       = "New"
  }

  # Enable boot diagnostics for the virtual machine and specify the storage account to use for storing boot diagnostics
  boot_diagnostics {
    enabled           = true
    storage_uri       = azurerm_storage_account.iAr-app-01-storage.primary_blob_endpoint
  }

  # Set the operating system disk for the virtual machine
  os_disk {
    name                 = "iAr-app01-vm-osdisk"
    disk_size_gb      = 30
    storage_account_type = "Standard_LRS"
  }

  # Grant access to the virtual machine to use the key vault
  # Add SQL Server maintenance plan that will schedule backups to the "F:" disk
  provisioner "local-exec" {
    inline = [
      "ssh -i iAr-app-01-key.pem azureuser@iAr-app01-vm 'sudo /opt/mssql-tools/bin/sqlcmd -i scripts/backup_plan_script.sql'",
    ]
  }

  # Configure Windows Firewall to allow remote access to SQL Server
  provisioner "remote-exec" {
    inline = [
      "Add-WindowsFeature -Name RSAT-TcpIp-Client -IncludeManagementTools",
      "New-NetFirewallRule `
       -DisplayName 'Remote SQL Server TCP Port 1433' `
  provisioner "remote-exec" {
    inline = [
      "New-NetFirewallRule `
       -DisplayName 'Remote SQL Server TCP Port 1433' `
       -Direction Inbound `
       -Protocol TCP `
       -LocalPort 1433 `
       -Action Allow `
       -Profile Any `
       -EdgeTraversal Allow",
      "Restart-Service WinRM",
    ]
  }

  # Grant access to the virtual machine to use the key vault
  resource "azurerm_role_assignment" "vm-key-vault-access" {
    role_definition_name = "Contributor"
    scope                = azurerm_virtual_machine.iAr-app01-vm.id
  }
}



#
#------------------- v2.0 -------------------
#

# Provider
provider "azurerm" {
  features {}
  version = ">= 2.0.0"
}

# Resource Group
resource "azurerm_resource_group" "iAr-app-01-RG" {
  name     = "iAr-app-01-RG"
  location = "westus"
}

# Virtual Network
resource "azurerm_virtual_network" "iAr-app01-vnet" {
  name                = "iAr-app01-vnet"
  location            = azurerm_resource_group.iAr-app-01-RG.location
  address_space       = ["10.0.0.0/16"]
  resource_group_id   = azurerm_resource_group.iAr-app-01-RG.id
  subnet_name_prefix  = "subnet"
  private_endpoint_subnet = true
}

# Subnet
resource "azurerm_subnet" "iAr-app01-subnet" {
  name                 = "iAr-app01-subnet"
  resource_group_id    = azurerm_resource_group.iAr-app-01-RG.id
  virtual_network_id   = azurerm_virtual_network.iAr-app01-vnet.id
  address_prefix       = "10.0.1.0/24"
}

# Network Interface
resource "azurerm_network_interface" "iAr-app01-nic" {
  name                = "iAr-app01-nic"
  resource_group_id   = azurerm_resource_group.iAr-app-01-RG.id
  virtual_network_id  = azurerm_virtual_network.iAr-app01-vnet.id
  subnet_id           = azurerm_subnet.iAr-app01-subnet.id
}

# Storage Account
resource "azurerm_storage_account" "iAr-app-01-storage" {
  name                  = "iAr-app-01-storage"
  resource_group_id    = azurerm_resource_group.iAr-app-01-RG.id
  location              = azurerm_resource_group.iAr-app-01-RG.location
  account_tier         = "Standard"
  account_replication_type = "LRS"
}

# Storage Container
resource "azurerm_storage_container" "iAr-app-01-backups" {
  name                = "backups"
  storage_account_id = azurerm_storage_account.iAr-app-01-storage.id
}

# Backup Policy
resource "azurerm_backup_policy" "iAr-app-01-backup" {
  name                = "iAr-app-01-backup"
  resource_group_id   = azurerm_resource_group.iAr-app-01-RG.id
  storage_account_id  = azurerm_storage_account.iAr-app-01-storage.id
  schedule            = "Weekly"
  policy_type         = "Full"
  retention_days      = 30
  schedule_start_time = "01:00"
  schedule_day_of_week = "Monday"
  schedule_month      = "01"
}

# Virtual Machine
resource "azurerm_virtual_machine" "iAr-app01-vm" {
  name                = "iAr-app01-vm"
  resource_group_id   = azurerm_resource_group.iAr-app-01-RG.id
  network_interface_ids = [azurerm_network_interface.iAr-app01-nic.id]
  vm_size             = "Standard_D2s_v3"

  storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  os_profile {
    computer_name  = "iAr-app01-vm"
    admin_username = "adminuser"
    admin_password = "P@ssw0rd1234!"
  }

  os_profile_windows_config {
    provision_vm_agent = true
    enable_automatic_upgrades = true
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.iAr-app-01-storage.primary_blob_endpoint
  }

  storage_os_disk {
    name              = "iAr-app01-vm-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  additional_data_disks {
    name              = "F"
    create_option     = "Empty"
    caching           = "None"
    disk_size_gb      = 1024
    managed_disk_type = "Premium_LRS"
  }

  provisioner "local-exec" {
    inline = [
      "ssh -i iAr-app-01-key.pem azureuser@iAr-app01-vm 'sudo /opt/mssql-tools/bin/sqlcmd -i scripts/backup_plan_script.sql'",
    ]
  }

  provisioner "remote-exec" {
    inline = [
      "Add-WindowsFeature -Name RSAT-TcpIp-Client -IncludeManagementTools",
      "New-NetFirewallRule -DisplayName 'Remote SQL Server TCP Port 1433' -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow -Profile Any -EdgeTraversal Allow",
      "Restart-Service WinRM",
    ]
  }
}

# Key Vault
resource "azurerm_key_vault" "iAr-app-01-key-vault" {
  name                = "iAr-app-01-key-vault"
  location            = azurerm_resource_group.iAr-app-01-RG.location
  resource_group_id   = azurerm_resource_group.iAr-app-01-RG.id
  enabled_for_disk_encryption = true
}

# Key Vault Access Policies
resource "azurerm_key_vault_access_policy" "admin-az-user1" {
  key_vault_id  = azurerm_key_vault.iAr-app-01-key-vault.id
  name          = "admin-az-user1"
  object_id     = azurerm_user_identity.admin-az-user1.id

  permissions = {
    keys           = ["Get", "Create", "Delete", "Recover", "Purge", "List"]
    secrets        = ["Get", "Set", "Delete", "Backup", "Restore", "List"]
    storage        = ["Get"]
    certificates   = ["Get"]
  }
}

resource "azurerm_key_vault_access_policy" "admin-az-user21" {
  key_vault_id  = azurerm_key_vault.iAr-app-01-key-vault.id
  name          = "admin-az-user21"
  object_id     = azurerm_user_identity.admin-az-user21.id

  permissions = {
    secrets        = ["Get", "List"]
  }
}

# Role Assignment for VM
resource "azurerm_role_assignment" "vm-key-vault-access" {
  role_definition_name = "Contributor"
  scope                = azurerm_virtual_machine.iAr-app01-vm.id
}

# ... (other configurations)

# Example: Public IP Address
resource "azurerm_public_ip" "example" {
  name                = "example-publicip"
  resource_group_name = azurerm_resource_group.iAr-app-01-RG.name
  location            = azurerm_resource_group.iAr-app-01-RG.location
  allocation_method   = "Dynamic"
}

# Example: Network Security Group
resource "azurerm_network_security_group" "example" {
  name                = "example-nsg"
  resource_group_name = azurerm_resource_group.iAr-app-01-RG.name
  location            = azurerm_resource_group.iAr-app-01-RG.location
}

# Example: Virtual Machine Extension
resource "azurerm_virtual_machine_extension" "example" {
  name                 = "hostname"
  virtual_machine_id   = azurerm_virtual_machine.iAr-app01-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "script": "./configure_hostname.sh"
    }
SETTINGS
}

# ... Add any other resources or configurations you need.

# Create a backend address pool for the load balancer
resource "azurerm_lb_backend_address_pool" "iAr" {
  name                = "iAr-backend-pool"
  resource_group_name = azurerm_resource_group.iAr-app-01-RG.name
  loadbalancer_id     = azurerm_lb.iAr.id
}

# Create a load balancer rule to forward traffic to the backend pool
resource "azurerm_lb_rule" "iAr" {
  name                  = "iAr-rule"
  resource_group_name   = azurerm_resource_group.iAr-app-01-RG.name
  loadbalancer_id       = azurerm_lb.iAr.id
  frontend_ip_configuration_id = azurerm_lb.iAr.frontend_ip_configuration[0].id
  backend_address_pool_id      = azurerm_lb_backend_address_pool.iAr.id
  frontend_port       = 80
  backend_port        = 80
  protocol            = "Tcp"
}

# Attach the virtual machine to the backend pool
resource "azurerm_network_interface_backend_address_pool_association" "iAr" {
  network_interface_id    = azurerm_network_interface.iAr-app01-nic.id
  ip_configuration_name   = azurerm_network_interface.iAr-app01-nic.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.iAr.id
}

# extras: 

# Variables
variable "admin_password" {
  description = "Password for the SQL Server admin"
}

# SQL Server Installation and Database Creation
resource "azurerm_virtual_machine_extension" "iAr-sql-setup" {
  name                 = "customscript"
  virtual_machine_id   = azurerm_virtual_machine.iAr-app01-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
        "script": "./scripts/install_sql.sh",
        "commandToExecute": "./install_sql.sh"
    }
SETTINGS

  protected_settings = <<PROTECTED_SETTINGS
    {
        "script": "./scripts/install_sql.sh"
    }
PROTECTED_SETTINGS
}

# Output
output "sql_server_ip" {
  value = azurerm_public_ip.iAr-sql.ip_address
}

output "load_balancer_ip" {
  value = azurerm_public_ip.iAr-lb.ip_address
}



