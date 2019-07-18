data "template_file" "salt-master-centos" {
    template = "${file("${format("%s/scripts/salt-master-centos.sh.tpl", path.module)}")}"
    vars {
        ROLE              = "${var.role}"
        SALT_VERSION      = "2019.2.0"
        RELEASE_VERSION   = "7"
        ARCHITECTURE      = "x86_64"
        SALTGUI_VERSION   = "1.16.0"
        SALT_USER         = "salt"
        CLOUDFLARE_EMAIL  = "${var.cloudflare_email}"
        CLOUDFLARE_TOKEN  = "${var.cloudflare_token}"
        CLOUDFLARE_ZONE   = "${var.cloudflare_zone}"
        CLOUDFLARE_RECORD = "${var.cloudflare_record}"
    }
}

data "template_file" "salt-master-ubuntu" {
    template = "${file("${format("%s/scripts/salt-master-ubuntu.sh.tpl", path.module)}")}"
    vars {
        ROLE            = "${var.role}"
        SALT_VERSION    = "2019.2.0"
        SALTGUI_VERSION = "1.16.0"
        DEBIAN_FRONTEND = "noninteractive"
        SALT_USER       = "salt"
    }
}

