variable "gcp_project" {
  description = "The GCP project ID"
}

variable "gcp_region" {
  description = "The GCP region"
}

variable "gcp_credentials_file" {
  description = "Path to the GCP credentials file"
}

variable "domain_name" {
  description = "The domain name"
}

variable "dkim_public_key" {
  description = "The DKIM public key"
}

variable "web_server_ip" {
  description = "The IP address of your web server"
}
