// These make use of the network we created in main.tf and the
// random_id value for unique naming

resource "google_compute_firewall" "firewall_ingress" {
  name      = "firewall-ingress-${random_id.random.hex}"
  network   = "${google_compute_network.network.name}"
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22", "3389", "5985-5986", "8000", "8080-8085", "9631"]
  }
}

resource "google_compute_firewall" "firewall_egress" {
  name      = "firewall-egress-${random_id.random.hex}"
  network   = "${google_compute_network.network.name}"
  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
}

resource "google_compute_firewall" "firewall_internal" {
  name      = "firewall-internal-${random_id.random.hex}"
  network   = "${google_compute_network.network.name}"
  direction = "INGRESS"

  // Internal firewall rules
  source_ranges = ["${data.google_compute_subnetwork.subnetwork.ip_cidr_range}"]

  allow {
    protocol = "tcp"
    ports    = ["8000", "8080-8085", "9631", "9638", "27017-27018"]
  }

  allow {
    protocol = "udp"
    ports    = ["9631", "9638"]
  }
}
