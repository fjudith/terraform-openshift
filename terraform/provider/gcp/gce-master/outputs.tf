output "name" {
  value = "${google_compute_instance.master.*.name}"
}
output "zone" {
  value = "${google_compute_instance.master.*.zone}"
}
output "internal_ip" {
  value = "${google_compute_instance.master.*.network_interface.0.network_ip}"
}

# output "external_ip" {
#   value = "${google_compute_instance.master.*.network_interface.0.access_config.0.nat_ip}"
# }

output "instance_link" {
  value = "${google_compute_instance.master.*.self_link}"  
}

output "cpu_platform" {
  value = "${google_compute_instance.master.*.cpu_platform}"  
}