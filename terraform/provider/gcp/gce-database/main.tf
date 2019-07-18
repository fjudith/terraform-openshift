

resource "random_shuffle" "az" {
  input = "${var.cluster_zones}"
  result_count = 1
}

resource "google_compute_disk" "database" {
  count = "${var.instance_count}"
  
  name = "${format("${var.name}-%03d", count.index + 1)}-database"

  zone = "${element(random_shuffle.az.result, 0)}"
  project = "${var.project}"
  
  type = "${var.database_disk_type}"
  size = "${var.database_disk_size_gb}"
}

resource "google_compute_disk" "backup" {
  count = "${var.instance_count}"
  
  name = "${format("${var.name}-%03d", count.index + 1)}-backup"

  zone = "${element(random_shuffle.az.result, 0)}"
  project = "${var.project}"
  
  type = "${var.database_disk_type}"
  size = "${var.database_disk_size_gb}"
}

resource "google_compute_instance" "node" {
  count = "${var.instance_count}"
  
  name = "${format("${var.name}-%03d", count.index + 1)}"
  project = "${var.project}"
  zone = "${element(random_shuffle.az.result, 0)}"
  machine_type = "${var.machine_type}"
  tags = ["${concat(list("allow-ssh"), var.target_tags)}"]
  labels = "${var.instance_labels}"

  allow_stopping_for_update = true

  connection {
    type                = "ssh"
    host                = "${self.network_interface.0.network_ip}"
    user                = "${var.ssh_user}"
    private_key         = "${file(var.ssh_private_key)}"
    agent               = false
    bastion_host        = "${var.bastion_host}"
    bastion_user        = "${var.ssh_user}"
    bastion_private_key = "${file(var.ssh_private_key)}"
    timeout             = "2m"
  }

  network_interface {
    network            = "${var.subnetwork == "" ? var.network : ""}"
    subnetwork         = "${var.subnetwork}"
    access_config      = ["${var.access_config}"]
    network_ip         = "${var.network_ip}"
    subnetwork_project = "${var.subnetwork_project == "" ? var.project : var.subnetwork_project}"
  }

  can_ip_forward = "${var.can_ip_forward}"

  boot_disk {
    initialize_params {
      image = "${var.compute_image}"
    }  
  }

  // backup SSD disk
  # scratch_disk {
  # }

  attached_disk {
      source = "${element(google_compute_disk.database.*.self_link, count.index)}",
      mode   = "${var.mode}"
      device_name = "database"
  }

  attached_disk {
      source = "${element(google_compute_disk.backup.*.self_link, count.index)}",
      mode   = "${var.mode}"
      device_name = "backup"
  }

  service_account {
    email  = "${var.service_account_email}"
    scopes = ["${var.service_account_scopes}"]
  }

  metadata = "${merge(
    map("startup-script", "${var.startup_script}", "tf_depends_id", "${var.depends_id}"),
    var.metadata
  )}"

  lifecycle {
    ignore_changes = ["attached_disk"]
  }

  provisioner "remote-exec" {
    inline = "${file("${format("%s/scripts/disk_mount.sh", path.module)}")}"
  }
}

resource "google_compute_firewall" "default-ssh" {

  project = "${var.subnetwork_project == "" ? var.project : var.subnetwork_project}"
  name    = "${var.name}-vm-ssh"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["${var.ssh_source_ranges}"]
  target_tags   = ["allow-ssh"]
}