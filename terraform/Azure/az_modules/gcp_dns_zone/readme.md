# GCP DNS Module

This Terraform module creates DNS records for Microsoft 365, DMARC, DKIM, SPF, and www in a Google Cloud DNS managed zone.

gcp_dns_module/
|-- main.tf
|-- variables.tf
|-- outputs.tf
|-- README.md

## Usage

```hcl
module "gcp_dns" {
  source = "./gcp_dns_module"

  gcp_project          = "your-gcp-project-id"
  gcp_region           = "us-central1"
  gcp_credentials_file = "path/to/your/gcp-credentials-file.json"

  domain_name      = "your-domain.com"
  dkim_public_key  = "your_dkim_public_key"
  web_server_ip    = "192.0.2.1"
}

output "dns_zone_id" {
  value = module.gcp_dns.dns_zone_id
}
