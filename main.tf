provider "google"{
	project = "golden-attic-452201-s8"
	region = "us-central1"
}

## VPC and Subnet
resource "google_compute_network" "vpc_network"{
	name = "cs-vpc"
	auto_create_subnetworks = false
}
resource "google_compute_subnetwork" "subnet"{
	name = "cs-subnet"
	network = google_compute_network.vpc_network.id
	ip_cidr_range = "10.0.1.0/24"
	region = "us-central1"
}

# NAT Gateway
resource "google_compute_router" "nat_router" {
  name    = "cs-nat-router"
  region  = "us-central1"
  network = google_compute_network.vpc_network.id
}

resource "google_compute_router_nat" "nat_gateway" {
  name                               = "cs-nat-gateway"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

## VM 
resource "google_compute_instance" "vm_instance" {
  name         = "cs-vm"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {}  
  }

  tags = ["web-server"]
}