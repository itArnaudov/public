provider "google" {
  credentials = file("path/to/credentials.json") # Replace with the path to your GCP service account key file
  project     = "your-gcp-project-id"            # Replace with your GCP project ID
  region      = "us-central1"                    # Replace with your desired GCP region
}

variable "resource_name" {
  default = "iAr-resources"
}

variable "subnet_name" {
  default = "internal"
}

variable "subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "instance_count" {
  default = 2
}

# Create VPC Network
resource "google_compute_network" "iAr" {
  name                    = var.resource_name
  auto_create_subnetworks = false
}

# Create Subnet
resource "google_compute_subnetwork" "iAr" {
  count                    = var.instance_count
  name                     = "${var.subnet_name}-${count.index}"
  network                  = google_compute_network.iAr.self_link
  ip_cidr_range            = var.subnet_cidr_block
  private_ip_google_access = true
}

# Create Instance Template
resource "google_compute_instance_template" "iAr" {
  name         = "iAr-instance-template"
  description  = "This template is used to create the app server instances"
  machine_type = "n1-standard-1" # Replace with your desired machine type

  disk {
    source_image = "debian-cloud/debian-10" # Replace with your desired OS image
  }

  network_interface {
    subnetwork = google_compute_subnetwork.iAr[count.index].self_link
  }

  metadata_startup_script = "echo 'Hello, World!' > index.html && python3 -m http.server 80"
}

# Create Managed Instance Group
resource "google_compute_instance_group_manager" "iAr" {
  provider           = google
  name               = "iAr-instance-group-manager"
  base_instance_name = "iAr-instance"
  zone               = "us-central1"
  version {
    name              = "iAr-app-server-canary"
    instance_template = google_compute_instance_template.iAr.id
  }

  #instance_template = google_compute_instance_template.iAr.id
  target_size = var.instance_count

  named_port {
    name = "http"
    port = 80
  }
}

# Create Internal Load Balancer
resource "google_compute_backend_service" "iAr" {
  name        = "iAr-backend-service"
  protocol    = "HTTP"
  timeout_sec = 30
  port_name   = "http"

  backend {
    group = google_compute_instance_group_manager.iAr.id
  }
}

resource "google_compute_url_map" "iAr" {
  name            = "iAr-url-map"
  default_service = google_compute_backend_service.iAr.id

}

resource "google_compute_target_http_proxy" "iAr" {
  name    = "iAr-http-proxy"
  url_map = google_compute_url_map.iAr.id
}

resource "google_compute_forwarding_rule" "iAr" {
  name                  = "iAr-forwarding-rule"
  target                = google_compute_target_http_proxy.iAr.id
  ip_protocol           = "TCP"
  port_range            = "80"
  load_balancing_scheme = "INTERNAL"
  network               = google_compute_subnetwork.iAr[0].network
  subnetwork            = google_compute_subnetwork.iAr[0].name
}
#
