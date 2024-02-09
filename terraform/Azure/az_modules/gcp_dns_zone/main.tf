provider "google" {
  credentials = file(var.gcp_credentials_file)
  project     = var.gcp_project
  region      = var.gcp_region
}

resource "google_dns_managed_zone" "dns_zone" {
  name        = "${var.domain_name}-dns-zone"
  dns_name    = "${var.domain_name}."
  description = "Managed zone for ${var.domain_name}."
}

resource "google_dns_record_set" "microsoft_365_mx" {
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = "@"
  type         = "MX"
  ttl          = 3600
  rrdatas      = ["0 pri1.mail.protection.outlook.com.", "10 pri2.mail.protection.outlook.com."]
}

resource "google_dns_record_set" "microsoft_365_txt" {
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = "@"
  type         = "TXT"
  ttl          = 3600
  rrdatas      = ["v=spf1 include:spf.protection.outlook.com -all"]
}

resource "google_dns_record_set" "microsoft_365_autodiscover" {
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = "autodiscover"
  type         = "CNAME"
  ttl          = 3600
  rrdatas      = ["autodiscover.outlook.com."]
}

resource "google_dns_record_set" "dmarc" {
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = "@"
  type         = "TXT"
  ttl          = 3600
  rrdatas      = ["v=DMARC1; p=none; rua=mailto:dmarc@example.com"]
}

resource "google_dns_record_set" "dkim" {
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = "selector1._domainkey"
  type         = "TXT"
  ttl          = 3600
  rrdatas      = ["v=DKIM1; k=rsa; p=${var.dkim_public_key}"]
}

resource "google_dns_record_set" "spf" {
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = "@"
  type         = "TXT"
  ttl          = 3600
  rrdatas      = ["v=spf1 include:spf.protection.outlook.com include:_spf.example.com -all"]
}

resource "google_dns_record_set" "www" {
  managed_zone = google_dns_managed_zone.dns_zone.name
  name         = "www"
  type         = "A"
  ttl          = 3600
  rrdatas      = [var.web_server_ip]
}
