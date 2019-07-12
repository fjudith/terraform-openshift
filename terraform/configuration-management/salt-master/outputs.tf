output "centos" {
    value = "${data.template_file.salt-master-centos.rendered}"
}

output "ubuntu" {
    value = "${data.template_file.salt-master-ubuntu.rendered}"
}