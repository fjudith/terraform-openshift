output "bastion_external" {
  value = "${module.bastion.external_ip}"
}

output "bastion_internal_ip" {
  value = "${module.bastion.internal_ip}"
}

output "gateway_external_ip" {
  value = "${module.gateway.external_ip}"
}

output "master_loadbalancer_external_ip" {
  value = "${module.master-loadbalancer.external_ip}"
}

output "node_loadbalancer_external_ip" {
  value = "${module.node-loadbalancer.external_ip}"
}