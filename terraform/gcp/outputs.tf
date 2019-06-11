output "national-parks-url" {
  value = "http://${google_compute_instance.national_parks.network_interface.0.access_config.0.nat_ip}:8080/national-parks"
}
