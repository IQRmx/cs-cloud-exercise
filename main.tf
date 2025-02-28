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