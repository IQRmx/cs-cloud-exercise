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
# Firewall 
resource "google_compute_firewall" "allow_ssh_http" {
  name    = "allow-ssh-http"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22", "80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}

# Firewall rule to allow internal db
resource "google_compute_firewall" "allow_internal_db" {
  name    = "allow-internal-db"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  source_ranges = ["10.0.1.0/24"]  
}

# Internal Ip for POSTGRES
resource "google_compute_global_address" "private_ip_alloc" {
  name          = "google-managed-services"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
}

# Connect VPC - PSOTGRES
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}

# DB 
resource "google_sql_database_instance" "cs_db" {
  name             = "cs-db"
  database_version = "POSTGRES_14"
  region           = "us-central1"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled    = false  # No public IP Address
      private_network = google_compute_network.vpc_network.id
    }
  }
}  