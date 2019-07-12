data "template_file" "salt-minion-centos" {
    template = "${file("${format("%s/scripts/salt-minion-centos.sh.tpl", path.module)}")}"
    vars {
        SALT_MASTER_HOST = "${var.salt_master}"
        ROLE            = "${var.role}"
        SALT_VERSION    = "2019.2.0"
        RELEASE_VERSION = "7"
        ARCHITECTURE    = "x86_64"
        SALT_USER       = "salt"
    }
}

data "template_file" "salt-minion-ubuntu" {
    template = "${file("${format("%s/scripts/salt-minion-ubuntu.sh.tpl", path.module)}")}"
    vars {
        SALT_MASTER_HOST = "${var.salt_master}"
        ROLE            = "${var.role}"
        SALT_VERSION    = "2019.2.0"
        DEBIAN_FRONTEND = "noninteractive"
        SALT_USER       = "salt"
    }
}