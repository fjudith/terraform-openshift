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

variable instance_count {
  description = "Number of GCE instance to create"
  default     = 1
}

variable project {
  description = "The project to deploy to, if not set the default provider project is used."
  default     = ""
}

variable region {
  description = "Region for cloud resources."
  default     = "us-central1"
}

variable zone {
  description = "Zone for managed instance groups."
  default     = "us-central1-f"
}

variable cluster_zones {
  description = "Zone for managed instance groups."
  type        = "list"
  default = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c",
  ]
}

variable network {
  description = "Name of the network to deploy instances to."
  default     = "default"
}

variable subnetwork {
  description = "The subnetwork to deploy to"
  default     = "default"
}

variable subnetwork_project {
  description = "The project the subnetwork belongs to. If not set, var.project is used instead."
  default     = ""
}

variable name {
  description = "Name of the managed instance group."
}

variable size {
  description = "Target size of the managed instance group."
  default     = 1
}

variable startup_script {
  description = "Content of startup-script metadata passed to the instance template."
  default     = ""
}

variable access_config {
  description = "The access config block for the instances. Set to [] to remove external IP."
  type        = "list"

  default = [
    {},
  ]
}

variable metadata {
  description = "Map of metadata values to pass to instances."
  type        = "map"
  default     = {}
}

variable can_ip_forward {
  description = "Allow ip forwarding."
  default     = false
}

variable network_ip {
  description = "Set the network IP of the instance in the template. Useful for instance groups of size 1."
  default     = ""
}

variable machine_type {
  description = "Machine type for the VMs in the instance group."
  default     = "f1-micro"
}

variable compute_image {
  description = "Image used for compute VMs."
  default     = "projects/debian-cloud/global/images/family/debian-9"
}

variable wait_for_instances {
  description = "Wait for all instances to be created/updated before returning"
  default     = false
}

# variable update_strategy {
#   description = "The strategy to apply when the instance template changes."
#   default     = "NONE"
# }

# variable rolling_update_policy {
#   description = "The rolling update policy when update_strategy is ROLLING_UPDATE"
#   type        = "list"
#   default     = []
# }

variable service_port {
  description = "Port the service is listening on."
}

variable service_port_name {
  description = "Name of the port the service is listening on."
}

variable target_tags {
  description = "Tag added to instances for firewall and networking."
  type        = "list"
  default     = ["allow-service"]
}

variable instance_labels {
  description = "Labels added to instances."
  type        = "map"
  default     = {}
}

variable target_pools {
  description = "The target load balancing pools to assign this group to."
  type        = "list"
  default     = []
}

variable depends_id {
  description = "The ID of a resource that the instance group depends on."
  default     = ""
}

variable service_account_email {
  description = "The email of the service account for the instance template."
  default     = "default"
}

variable service_account_scopes {
  description = "List of scopes for the instance template service account"
  type        = "list"

  default = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring.write",
    "https://www.googleapis.com/auth/devstorage.full_control",
  ]
}


variable ssh_source_ranges {
  description = "Network ranges to allow SSH from"
  type        = "list"
  default     = ["0.0.0.0/0"]
}

variable disk_auto_delete {
  description = "Whether or not the disk should be auto-deleted."
  default     = true
}

variable disk_type {
  description = "The GCE disk type. Can be either pd-ssd, local-ssd, or pd-standard."
  default     = "pd-ssd"
}

variable disk_size_gb {
  description = "The size of the image in gigabytes. If not specified, it will inherit the size of its base image."
  default     = 0
}

variable etcd_disk_type {
  description = "The Etcd dedicated GCE disk type. Can be either pd-ssd, local-ssd, or pd-standard."
  default     = "pd-ssd"
}

variable etcd_disk_size_gb {
  description = "The Etcd dedicated size of the image in gigabytes."
  default     = 5
}

variable containers_disk_type {
  description = "Containers dedicated GCE disk type. Can be either pd-ssd, local-ssd, or pd-standard."
  default     = "pd-ssd"
}

variable containers_disk_size_gb {
  description = "Containers dedicated size of the image in gigabytes."
  default     = 5
}

variable local_disk_type {
  description = "The Local Volume dedicated GCE disk type. Can be either pd-ssd, local-ssd, or pd-standard."
  default     = "pd-ssd"
}

variable local_disk_size_gb {
  description = "The Local Volume dedicated size of the image in gigabytes."
  default     = 5
}

variable mode {
  description = "The mode in which to attach this disk, either READ_WRITE or READ_ONLY."
  default     = "READ_WRITE"
}

variable "preemptible" {
  description = "Use preemptible instances - lower price but short-lived instances. See https://cloud.google.com/compute/docs/instances/preemptible for more details"
  default     = "false"
}

variable "automatic_restart" {
  description = "Automatically restart the instance if terminated by GCP - Set to false if using preemptible instances"
  default     = "true"
}

/* Health checks */
variable http_health_check {
  description = "Enable or disable the http health check for auto healing."
  default     = true
}

variable hc_initial_delay {
  description = "Health check, intial delay in seconds."
  default     = 30
}

variable hc_interval {
  description = "Health check, check interval in seconds."
  default     = 30
}

variable hc_timeout {
  description = "Health check, timeout in seconds."
  default     = 10
}

variable hc_healthy_threshold {
  description = "Health check, healthy threshold."
  default     = 1
}

variable hc_unhealthy_threshold {
  description = "Health check, unhealthy threshold."
  default     = 10
}

variable hc_port {
  description = "Health check, health check port, if different from var.service_port, if not given, var.service_port is used."
  default     = ""
}

variable hc_path {
  description = "Health check, the http path to check."
  default     = "/"
}

variable ssh_fw_rule {
  description = "Whether or not the SSH Firewall Rule should be created"
  default     = true
}

variable "ssh_user" {
  description = "Username to connect the server"
  default     = "root"
}

variable "ssh_private_key" {
  description = "Path to your private SSH key path"
  default     = "~/.ssh/id_rsa"
}

variable "bastion_host" {
  description = "Ip address, Hostname or FQDN of the SSH bastion hsot"
  default     = "bastion.domain.tld"
}