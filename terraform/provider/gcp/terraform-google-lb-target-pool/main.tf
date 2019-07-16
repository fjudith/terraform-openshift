/*
 * Copyright 2017 Google Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Static IP address for HTTP forwarding rule
resource "google_compute_address" "default" {
  region  = "${var.region}"
  project = "${var.project}"
  name    = "${var.name}-lb-target-pool"
}

resource "google_compute_http_health_check" "default" {
  project      = "${var.project}"
  name         = "${var.name}-target-group-hc"
  check_interval_sec = 10
  timeout_sec = 10
  healthy_threshold = 3
  unhealthy_threshold = 3

  request_path = "/healthz"
  port         = "1936"
}

resource "google_compute_target_pool" "default" {
  count            = "${length(var.service_port_name)}"

  project          = "${var.project}"
  name             = "${element(var.service_port_name, count.index)}-target-pool"
  region           = "${var.region}"
  # session_affinity = "${var.session_affinity}"

  # backup_pool = "${var.instance_group}"

  health_checks = [
    "${google_compute_http_health_check.default.name}",
  ]
}

resource "google_compute_forwarding_rule" "default" {
  count       = "${length(var.service_port_name)}"

  region      = "${var.region}"
  project     = "${var.project}"
  name        = "${element(var.service_port_name, count.index)}-frontend"
  target      = "${element(google_compute_target_pool.default.*.self_link, count.index)}"
  port_range  = "${element(var.service_port, count.index)}"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.default.address}"
}

resource "google_compute_firewall" "default-lb-fw" {
  count   = "${length(var.service_port)}"

  project = "${var.firewall_project == "" ? var.project : var.firewall_project}"
  name    = "${element(var.service_port_name, count.index)}-service"
  network = "${var.network}"

  allow {
    protocol = "tcp"
    ports    = ["${element(var.service_port, count.index)}"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.target_tags}"]
}