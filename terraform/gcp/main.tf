provider "google" {
  credentials = "${file("${var.gcp_credentials_file}")}"
  project     = "${var.gcp_project}"
  region      = "${var.gcp_region}"
}

resource "random_id" "random" {
  byte_length = 4
}

resource "google_compute_network" "network" {
  name = "network-${random_id.random.hex}"
}

data "google_compute_subnetwork" "subnetwork" {
  name = "${google_compute_network.network.name}"
}

data "google_compute_zones" "available" {}
