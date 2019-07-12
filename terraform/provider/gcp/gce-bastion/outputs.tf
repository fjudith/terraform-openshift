output "external_ip" {
  value = "${element(concat(google_compute_instance.bastion.*.network_interface.0.access_config.0.nat_ip, list("")), 0)}"
}

output "primary_ip" {
  value = "${element(concat(google_compute_instance.bastion.*.network_interface.0.network_ip, list("")), 0)}"
}