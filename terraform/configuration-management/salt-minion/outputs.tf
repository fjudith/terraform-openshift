output "centos" {
    value = "${data.template_file.salt-minion-centos.rendered}"
}

output "ubuntu" {
    value = "${data.template_file.salt-minion-ubuntu.rendered}"
}