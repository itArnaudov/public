provider "azurerm" {
  features = {}
}

resource "azurerm_resource_group" "iAr-private124_rg" {
  name     = "iAr-private124-rg"
  location = "East US"  # Change to your desired Azure region
}

resource "azurerm_dns_zone" "iAr-private124_dns" {
  name                = "iAr-private124.com"
  resource_group_name = azurerm_resource_group.private124_rg.name
}

resource "azurerm_dns_mx_record" "iAr-microsoft_365_mx" {
  name                = "@"
  zone_name           = azurerm_dns_zone.private124_dns.name
  resource_group_name = azurerm_resource_group.private124_rg.name
  ttl                 = 3600
  records             = ["0 pri1.mail.protection.outlook.com.", "10 pri2.mail.protection.outlook.com."]
}

resource "azurerm_dns_txt_record" "iAr-microsoft_365_txt" {
  name                = "@"
  zone_name           = azurerm_dns_zone.private124_dns.name
  resource_group_name = azurerm_resource_group.private124_rg.name
  ttl                 = 3600
  records             = ["v=spf1 include:spf.protection.outlook.com -all"]
}

resource "azurerm_dns_cname_record" "iAr-microsoft_365_autodiscover" {
  name                = "autodiscover"
  zone_name           = azurerm_dns_zone.private124_dns.name
  resource_group_name = azurerm_resource_group.private124_rg.name
  ttl                 = 3600
  record {
    cname = "autodiscover.outlook.com"
  }
}

resource "azurerm_dns_txt_record" "iAr-dmarc" {
  name                = "@"
  zone_name           = azurerm_dns_zone.private124_dns.name
  resource_group_name = azurerm_resource_group.private124_rg.name
  ttl                 = 3600
  records             = ["v=DMARC1; p=none; rua=mailto:dmarc@example.com"]
}

resource "azurerm_dns_txt_record" "iAr-dkim" {
  name                = "selector1._domainkey"
  zone_name           = azurerm_dns_zone.private124_dns.name
  resource_group_name = azurerm_resource_group.private124_rg.name
  ttl                 = 3600
  records             = ["v=DKIM1; k=rsa; p=your_dkim_public_key"]
}

resource "azurerm_dns_txt_record" "iAr-spf" {
  name                = "@"
  zone_name           = azurerm_dns_zone.private124_dns.name
  resource_group_name = azurerm_resource_group.private124_rg.name
  ttl                 = 3600
  records             = ["v=spf1 include:spf.protection.outlook.com include:_spf.example.com -all"]
}

resource "azurerm_dns_a_record" "iAr-www" {
  name                = "www"
  zone_name           = azurerm_dns_zone.private124_dns.name
  resource_group_name = azurerm_resource_group.private124_rg.name
  ttl                 = 3600
  records             = ["192.0.2.1"]  # Change to your web server IP address
}

output "dns_zone_id" {
  value = azurerm_dns_zone.private124_dns.id
}
