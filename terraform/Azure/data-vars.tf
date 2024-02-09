#Usage: Backup - VM backend IP address
data "azurerm_virtual_machine" "vm_dev_1" {
  depends_on          = [module.vm-windows-deploy]
  name                = var.vm_dev_1
  resource_group_name = var.rg_name
}

#Usage: Application Gateway - Backend Pool Loadbalancer configuration
/* data "azurerm_lb" "lb1_uat1" {
  depends_on = [azurerm_lb.lb1-uat1]
  name                = "${var.env_uat}-${var.app_name}-lb1"
  resource_group_name = rg_name
}

data "azurerm_lb" "lb1_uat1" {
  depends_on = [azurerm_lb.lb1-uat1]
  name                = "${var.env_uat}-${var.app_name}-lb1"
  resource_group_name = var.rg_name
} */

#Usage: Application Gateway - Certificate retrieval from storage
/* data "azurerm_key_vault" "kv1" {
  depends_on          = [module.keyvault]
  name                = "${var.envt}-${var.app_name}-kv1-new"
  resource_group_name = var.rg_name
} */

/* data "azurerm_key_vault_certificate" "ag_uat1_crt1_name_1" {
  depends_on = [module.keyvault, azurerm_key_vault_access_policy.kv_access_managed_identity]
  name         = var.ag_uat1_crt1_name_1
  key_vault_id = data.azurerm_key_vault.kv1.id
}

data "azurerm_key_vault_certificate" "ag_uat1_crt1_name_1" {
  name         = var.ag_uat1_crt1_name_1
  key_vault_id = data.azurerm_key_vault.kv1.id
} */

#Usage: Traffic manager - route to AppGW
/* data "azurerm_pub_ip" "tm_pub_ip_uks1" {
  depends_on = [module.appgateway-waf]
  name                = "${var.envt}-${var.app_name}-waf1-pip1"
  resource_group_name = var.rg_name
}
 */
/* data "azurerm_public_ip" "tm_pub_ip_2" {
  depends_on = [module.appgateway-waf1-dr1]
  name                = var.tm_pub_ip_2
  resource_group_name = var.dr_rg_name
} */
/* 
data "azurerm_public_ip" "tm_pub_ip_lb1_uat1" {
  depends_on          = [azurerm_pub_ip.frontend_pip1_uat1]
  name                = "${var.env_uat}-${var.app_name}-lb1-pip1"
  resource_group_name = var.rg_name
}

data "azurerm_public_ip" "tm_pub_ip_lb1_uat1" {
  depends_on          = [azurerm_pub_ip.frontend_pip1_uat1]
  name                = "${var.env_uat}-${var.app_name}-lb1-pip1"
  resource_group_name = var.rg_name
} */

#Usage: LB - Nic associations
data "azurerm_network_interface" "vm_dev_1_nic1" {
  depends_on          = [module.vm-windows-deploy]
  name                = "${var.vm_dev_1}-nic1"
  resource_group_name = var.rg_name
}

/* data "azurerm_virtual_network" "internal_prv" {
  name                = var.vnet1_name1
  resource_group_name = var.vnet_rg_name
}
 */
