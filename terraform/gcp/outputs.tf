output "national-parks-ip" {
  value = "${google_compute_instance.national_parks.*.network_interface.0.access_config.0.nat_ip}"
}
