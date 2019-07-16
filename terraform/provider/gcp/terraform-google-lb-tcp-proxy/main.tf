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
resource "google_compute_global_address" "default" {
  project = "${var.project}"
  name    = "${var.name}-lb-tcp-proxy"
}


resource "google_compute_health_check" "default" {
  project            = "${var.project}"
  name               = "${var.name}-tcp-proxy-hc"
  check_interval_sec = 10
  timeout_sec        = 10
  healthy_threshold  = 3
  unhealthy_threshold = 3

  tcp_health_check {
    # request_path       = "/healthz"
    port               = 443
  }
}

// TCP/SSL service ports
resource "google_compute_backend_service" "default" {
  count       = "${length(var.service_port_name)}"

  project     = "${var.project}"
  name        = "${element(var.service_port_name, count.index)}-backend"
  protocol    = "TCP"
  port_name   = "${element(var.service_port_name, count.index)}"
  timeout_sec = 10
  session_affinity = "${var.session_affinity}"

  backend {
    group = "${var.instance_group}"
  }

  health_checks = ["${google_compute_health_check.default.self_link}"]
}

resource "google_compute_target_tcp_proxy" "default" {
  # count           = "${length(google_compute_backend_service.default.*.self_link)}"
  count       = "${length(var.service_port_name)}"

  project         = "${var.project}"
  name            = "${element(var.service_port_name, count.index)}-tcp-proxy"
  description     = "${element(var.service_port_name, count.index)} lb tcp proxy"
  backend_service = "${element(google_compute_backend_service.default.*.self_link, count.index)}"
}

resource "google_compute_global_forwarding_rule" "default" {
  # count       = "${length(google_compute_target_tcp_proxy.default.*.self_link)}"
  count       = "${length(var.service_port_name)}"

  project     = "${var.project}"
  name        = "${element(var.service_port_name, count.index)}-frontend"
  target      = "${element(google_compute_target_tcp_proxy.default.*.self_link, count.index)}"
  port_range  = "${element(var.service_port, count.index)}"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_global_address.default.address}"
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