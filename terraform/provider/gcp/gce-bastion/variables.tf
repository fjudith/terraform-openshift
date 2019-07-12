variable "ssh_public_key" {}

variable "region" {
  default = "us-central1"
}

variable "project" {}
variable "res_prefix" {}

variable "subnet_cidr" {
  default = "10.128.0.0/20"
}

variable "bastion_create" {
  default = false
}

variable "bastion_type" {
  default = "n1-standard-1"
}

variable "bastion_image" {
  default = "ubuntu-os-cloud/ubuntu-1604-lts"
}

variable "owner" {}


variable "network" {
  default = "default"
}

variable "subnetwork" {
  default = "default"
}

variable "cluster_zones" {
  default = [
    "us-central1-a",
    "us-central1-b",
    "us-central1-c",
  ]
}

variable startup_script {
  description = "Content of startup-script metadata passed to the instance template."
  default     = ""
}