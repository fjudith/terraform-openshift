variable "host_count" {}

variable "email" {}

variable "token" {}

variable "domain" {}

variable "subdomain" {}

variable "hostnames" {
  type = "list"
}

variable "master_lb_ip" {
  type = "list"
}

variable "node_lb_ip" {
  type = "list"
}

variable "bastion_host" {
  default = "bastion"
}
variable "bastion_create" {
  default = false
}

variable "bastion_ip" {
  default = ["1.2.3.4"]
}