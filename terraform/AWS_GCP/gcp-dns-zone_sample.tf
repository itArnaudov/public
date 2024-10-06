provider "google" {
  credentials = file("<path_to_your_gcp_credentials_file>")
  project     = "your-gcp-project-id"
  region      = "us-central1" # Change to your desired GCP region
}

resource "google_dns_managed_zone" "iar_private124_dns" {
  name        = "iar-private124-com"
  dns_name    = "iar-private124.com."
  description = "Managed zone for iar-private124.com."
}

resource "google_dns_record_set" "iar_microsoft_365_mx" {
  managed_zone = google_dns_managed_zone.iar_private124_dns.name
  name         = "@"
  type         = "MX"
  ttl          = 3600
  rrdatas      = ["0 pri1.mail.protection.outlook.com.", "10 pri2.mail.protection.outlook.com."]
}

resource "google_dns_record_set" "iar_microsoft_365_txt" {
  managed_zone = google_dns_managed_zone.iar_private124_dns.name
  name         = "@"
  type         = "TXT"
  ttl          = 3600
  rrdatas      = ["v=spf1 include:spf.protection.outlook.com -all"]
}

resource "google_dns_record_set" "iar_microsoft_365_autodiscover" {
  managed_zone = google_dns_managed_zone.iar_private124_dns.name
  name         = "autodiscover"
  type         = "CNAME"
  ttl          = 3600
  rrdatas      = ["autodiscover.outlook.com."]
}

resource "google_dns_record_set" "iar_dmarc" {
  managed_zone = google_dns_managed_zone.iar_private124_dns.name
  name         = "@"
  type         = "TXT"
  ttl          = 3600
  rrdatas      = ["v=DMARC1; p=none; rua=mailto:dmarc@example.com"]
}

resource "google_dns_record_set" "iar_dkim" {
  managed_zone = google_dns_managed_zone.iar_private124_dns.name
  name         = "selector1._domainkey"
  type         = "TXT"
  ttl          = 3600
  rrdatas      = ["v=DKIM1; k=rsa; p=your_dkim_public_key"]
}

resource "google_dns_record_set" "iar_spf" {
  managed_zone = google_dns_managed_zone.iar_private124_dns.name
  name         = "@"
  type         = "TXT"
  ttl          = 3600
  rrdatas      = ["v=spf1 include:spf.protection.outlook.com include:_spf.example.com -all"]
}

resource "google_dns_record_set" "iar_www" {
  managed_zone = google_dns_managed_zone.iar_private124_dns.name
  name         = "www"
  type         = "A"
  ttl          = 3600
  rrdatas      = ["192.0.2.1"] # Change to your web server IP address
}
