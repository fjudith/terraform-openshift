output "internal_ip" {
  value = "${google_compute_instance.node.*.network_interface.0.network_ip}"
}

# output "external_ip" {
#   value = "${element(concat(google_compute_instance.node.*.network_interface.0.access_config.0.nat_ip, list("")), 0)}"
# }

output "instance_link" {
  value = "${google_compute_instance.node.*.self_link}"  
}

output "cpu_platform" {
  value = "${google_compute_instance.node.*.cpu_platform}"  
}