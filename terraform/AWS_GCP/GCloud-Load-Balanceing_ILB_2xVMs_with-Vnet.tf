//This Terraform code creates a VPC network, subnets, backend VM instances, an instance group, and an internal load balancer using Google Cloud Load Balancing. 
//Adjust the parameters, such as machine type, image, region, and other settings according to your requirements. 
//Also, make sure to replace "`path/to/your/credentials.json`" and "`your-gcp-project-id`" with your actual service account credentials file path and GCP project ID.
provider "google" {
  credentials = file("path/to/your/credentials.json")
  project     = "your-gcp-project-id"
  region      = "us-central1" # Change to your desired region
}

variable "subnet_cidr_block" {
  default = "10.0.1.0/24"
}

variable "backend_vm_count" {
  default = 2
}

# Create a VPC network
resource "google_compute_network" "iAr" {
  name = "internal-network"
}

# Create a subnet
resource "google_compute_subnetwork" "iAr" {
  count         = var.backend_vm_count
  name          = "internal-subnet-${count.index}"
  network       = google_compute_network.iAr.self_link
  ip_cidr_range = var.subnet_cidr_block
  region        = "us-central1" # Change to your desired region
}

# Create backend VM instances
resource "google_compute_instance" "iAr" {
  count        = var.backend_vm_count
  name         = "vm-${count.index + 1}"
  machine_type = "n1-standard-1" # Change to your desired machine type
  zone         = "us-central1-a" # Change to your desired zone
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.iAr[count.index].self_link
  }
}

# Create an internal load balancer
resource "google_compute_backend_service" "iAr" {
  name          = "internal-backend-service"
  health_checks = [] # Add health checks if needed
  backends {
    group = google_compute_instance_group.iAr.self_link
  }
}

resource "google_compute_instance_group" "iAr" {
  name              = "instance-group"
  instance_template = google_compute_instance_template.iAr.self_link
  named_port {
    name = "http"
    port = 80
  }
}

resource "google_compute_instance_template" "iAr" {
  name = "instance-template"
  instance {
    machine_type = "n1-standard-1" # Change to your desired machine type
    disk {
      source_image = "debian-cloud/debian-10"
    }
  }
  network_interface {
    network = google_compute_network.iAr.self_link
  }
}

resource "google_compute_region_backend_service" "iAr" {
  name            = "region-backend-service"
  region          = "us-central1" # Change to your desired region
  backend_service = google_compute_backend_service.iAr.self_link
}

resource "google_compute_global_forwarding_rule" "iAr" {
  name       = "internal-forwarding-rule"
  target     = google_compute_region_backend_service.iAr.self_link
  port_range = "80"
}

# Output the IP address of the load balancer
output "load_balancer_ip" {
  value = google_compute_global_forwarding_rule.iAr.ip_address
}
#
#=========================================================================================
#
