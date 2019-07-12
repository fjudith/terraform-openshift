resource "google_compute_firewall" "bastion-ext" {
  count   = "${var.bastion_create ? 1 : 0}"
  name    = "${var.res_prefix}-ext-fw"
  network = "${var.network}"
  project = "${var.project}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["bastion"]
}

resource "google_compute_firewall" "bastion-int" {
  name    = "${var.res_prefix}-int-fw"
  network = "${var.network}"
  project = "${var.project}"

  allow {
    protocol = "all"
  }

  source_ranges = ["${var.subnet_cidr}"]
}

resource "google_compute_firewall" "bastion-int-egress" {
  name    = "${var.res_prefix}-int-egress-fw"
  network = "${var.network}"
  project = "${var.project}"

  allow {
    protocol = "all"
  }

  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
}
resource "google_compute_instance" "bastion" {
  count        = "${var.bastion_create ? 1 : 0}"
  name         = "${var.res_prefix}-bastion"
  machine_type = "${var.bastion_type}"
  zone         = "${var.az}"
  project      = "${var.project}"
  tags         = ["bastion"]
  zone         = "${var.cluster_zones[count.index]}"
  

  boot_disk {
    initialize_params {
      image = "${var.bastion_image}"
    }
  }

  metadata {
    ssh-keys = "${file("${var.ssh_public_key}")}"
  }

  metadata_startup_script = "${var.startup_script}"

  network_interface {
    subnetwork    = "${var.subnetwork}"
    access_config = {}
  }
}